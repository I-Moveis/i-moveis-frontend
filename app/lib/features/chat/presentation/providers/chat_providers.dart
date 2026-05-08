import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/secure_storage_provider.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../core/services/fcm_service_provider.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../data/models/chat_models.dart';
import '../../data/providers/data_providers.dart';

final sessionsProvider = AsyncNotifierProvider<SessionsNotifier, List<ChatSessionModel>>(
  SessionsNotifier.new,
);

class SessionsNotifier extends AsyncNotifier<List<ChatSessionModel>> {
  StreamSubscription<MessageModel>? _newMessageSub;
  StreamSubscription<Map<String, dynamic>>? _sessionUpdatedSub;
  StreamSubscription<Object?>? _fcmSub;

  static const _cacheKey = 'chat_sessions_cache';

  @override
  Future<List<ChatSessionModel>> build() async {
    _listenToSocket();
    _listenToFcm();
    ref.onDispose(() {
      _newMessageSub?.cancel();
      _sessionUpdatedSub?.cancel();
      _fcmSub?.cancel();
    });

    // Cache-first: mostra dados antigos imediatamente
    final cached = await _loadCache();
    if (cached != null && cached.isNotEmpty) {
      state = AsyncData(cached);
    }

    return _fetchAndCache();
  }

  Future<List<ChatSessionModel>> _fetchAndCache() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    final authState = ref.read(authNotifierProvider);
    final isOwner = authState.maybeWhen(
      authenticated: (user) => user.isOwner,
      orElse: () => false,
    );
    final isAdmin = authState.maybeWhen(
      authenticated: (user) => user.isAdmin,
      orElse: () => false,
    );

    final api = ref.read(chatApiDataSourceProvider);
    List<ChatSessionModel> sessions;

    if (isAdmin) {
      sessions = await api.listSessions(status: 'WAITING_HUMAN');
    } else if (isOwner) {
      sessions = await api.listSessions(landlordId: userId, status: 'WAITING_HUMAN');
    } else {
      sessions = await api.listSessions(tenantId: userId);
    }

    _saveCache(sessions);
    return sessions;
  }

  Future<List<ChatSessionModel>?> _loadCache() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final json = prefs.getString(_cacheKey);
      if (json == null) return null;
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => ChatSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCache(List<ChatSessionModel> sessions) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final json = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_cacheKey, json);
    } catch (_) {}
  }

  void _listenToFcm() {
    _fcmSub?.cancel();
    final fcmService = ref.read(fcmServiceProvider);
    if (fcmService == null) return;
    _fcmSub = fcmService.onMessage.listen((msg) {
      final data = msg.data;
      final type = data['type'];
      if (type == 'new_message' || type == 'DOCUMENT_REQUESTED' || type == 'RENTAL_STAGE_CHANGED') {
        refresh();
      }
    });
  }

  void _listenToSocket() {
    _newMessageSub?.cancel();
    _sessionUpdatedSub?.cancel();

    final socket = ref.read(chatSocketDataSourceProvider);
    _newMessageSub = socket.onNewMessage.listen((msg) {
      final sessions = state.asData?.value;
      if (sessions == null) return;
      final idx = sessions.indexWhere((s) => s.id == msg.sessionId);
      if (idx < 0) {
        refresh();
        return;
      }

      final updated = sessions[idx];
      final newSessions = List<ChatSessionModel>.from(sessions)
        ..removeAt(idx)
        ..insert(
          0,
          ChatSessionModel(
            id: updated.id,
            tenantId: updated.tenantId,
            propertyId: updated.propertyId,
            propertyTitle: updated.propertyTitle,
            propertyLandlordId: updated.propertyLandlordId,
            status: updated.status,
            startedAt: updated.startedAt,
            expiresAt: updated.expiresAt,
            tenantName: updated.tenantName,
            tenantPhone: updated.tenantPhone,
            messageCount: (updated.messageCount ?? 0) + 1,
            lastMessage: msg.content,
            lastSenderType: msg.senderType,
            lastMessageAt: msg.timestamp,
          ),
        );
      state = AsyncData(newSessions);
      _saveCache(newSessions);
    });

    _sessionUpdatedSub = socket.onSessionUpdated.listen((data) {
      final sessions = state.asData?.value;
      if (sessions == null) return;
      final sessionId = data['sessionId'] as String?;
      final newStatus = data['status'] as String?;
      if (sessionId == null || newStatus == null) return;
      final idx = sessions.indexWhere((s) => s.id == sessionId);
      if (idx < 0) return;

      final updated = sessions[idx];
      final newSessions = List<ChatSessionModel>.from(sessions);
      newSessions[idx] = ChatSessionModel(
        id: updated.id,
        tenantId: updated.tenantId,
        propertyId: updated.propertyId,
        propertyTitle: updated.propertyTitle,
        propertyLandlordId: updated.propertyLandlordId,
        status: newStatus,
        startedAt: updated.startedAt,
        expiresAt: updated.expiresAt,
        tenantName: updated.tenantName,
        tenantPhone: updated.tenantPhone,
        messageCount: updated.messageCount,
        lastMessage: updated.lastMessage,
        lastSenderType: updated.lastSenderType,
        lastMessageAt: updated.lastMessageAt,
      );
      state = AsyncData(newSessions);
      _saveCache(newSessions);
    });
  }

  Future<String?> _getUserId() async {
    try {
      final storage = ref.read(secureTokenStorageProvider);
      return await storage.readUserId();
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetchAndCache());
  }
}

final sessionMessagesProvider =
    FutureProvider.family<List<MessageModel>, String>((ref, sessionId) async {
  final api = ref.read(chatApiDataSourceProvider);
  final session = await api.getSession(sessionId);
  final messagesRaw = (session as dynamic).messages;
  if (messagesRaw is List) {
    return (messagesRaw)
        .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }
  return [];
});

final sendChatMessageProvider =
    FutureProvider.family<MessageModel, ({String sessionId, String content})>(
  (ref, params) async {
    final api = ref.read(chatApiDataSourceProvider);
    return await api.sendMessage(
      sessionId: params.sessionId,
      senderType: 'LANDLORD',
      content: params.content,
    );
  },
);
