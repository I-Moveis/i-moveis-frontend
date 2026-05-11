import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants.dart';

class SocketService {
  io.Socket? _socket;

  final _newMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _sessionUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _ticketMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _ticketUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNewMessage =>
      _newMessageController.stream;
  Stream<Map<String, dynamic>> get onSessionUpdated =>
      _sessionUpdatedController.stream;
  Stream<Map<String, dynamic>> get onTicketMessage =>
      _ticketMessageController.stream;
  Stream<Map<String, dynamic>> get onTicketUpdated =>
      _ticketUpdatedController.stream;

  bool get isConnected => _socket?.connected ?? false;

  // Deriva a base URL do WebSocket a partir de kApiBaseUrl (remove /api suffix)
  String get _wsUrl {
    final base = kApiBaseUrl;
    if (base.endsWith('/api')) return base.substring(0, base.length - 4);
    return base;
  }

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[Socket] sem usuário autenticado, abortando conexão');
      return;
    }

    final token = await user.getIdToken();
    if (token == null) {
      debugPrint('[Socket] token nulo, abortando conexão');
      return;
    }

    _socket = io.io(
      _wsUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': 'Bearer $token'})
          .build(),
    );

    _socket!.on('connect', (_) {
      debugPrint('[Socket] ✅ conectado a $_wsUrl');
    });

    _socket!.on('disconnect', (_) {
      debugPrint('[Socket] ❌ desconectado');
    });

    _socket!.on('connect_error', (err) {
      debugPrint('[Socket] ⚠️ erro de conexão: $err');
    });

    _socket!.on('new_message', (data) {
      if (data != null) {
        debugPrint('[Socket] 💬 new_message recebido');
        _newMessageController.add(data as Map<String, dynamic>);
      }
    });

    _socket!.on('session_updated', (data) {
      if (data != null) {
        debugPrint('[Socket] 🔄 session_updated recebido');
        _sessionUpdatedController.add(data as Map<String, dynamic>);
      }
    });

    _socket!.on('support_ticket_message', (data) {
      if (data != null) {
        debugPrint('[Socket] 🎫 support_ticket_message recebido');
        _ticketMessageController.add(data as Map<String, dynamic>);
      }
    });

    _socket!.on('support_ticket_updated', (data) {
      if (data != null) {
        debugPrint('[Socket] 🔄 support_ticket_updated recebido');
        _ticketUpdatedController.add(data as Map<String, dynamic>);
      }
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    debugPrint('[Socket] desconectado manualmente');
  }

  void joinTicket(String ticketId) {
    _socket?.emit('join_ticket', ticketId);
  }

  void leaveTicket(String ticketId) {
    _socket?.emit('leave_ticket', ticketId);
  }

  void dispose() {
    disconnect();
    _newMessageController.close();
    _sessionUpdatedController.close();
    _ticketMessageController.close();
    _ticketUpdatedController.close();
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(service.dispose);
  return service;
});
