import 'dart:async';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';

/// VAPID key do Firebase Console → Project settings → Cloud Messaging →
/// Web Push certificates. Chave pública (não é segredo), requerida pelo
/// `FirebaseMessaging.getToken` no web.
const String _kWebVapidKey =
    'BAMXHuM7qgq3AS2tzLbaHQNriiV3lQE30ZM2ocraJtovv7Ba8d41FawvFOMfiB2rTH6AVvHztAtAadnD_Urvd5k';

/// Background handler — precisa ser top-level por exigência do plugin
/// (o isolate é reinstanciado, não pega closures da classe).
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Background notifications são exibidas pelo SO (Android) / SW (web) a partir
  // do payload `notification`. Só logamos aqui pra trilha de debug.
  debugPrint('[fcm.bg] ${message.messageId} ${message.data}');
}

/// Serviço central de Firebase Cloud Messaging.
///
/// Responsabilidades:
///   1. Inicializar Firebase + canal de notificação local (Android).
///   2. Pedir permissão ao usuário (obrigatório Android 13+ e iOS/web).
///   3. Obter o FCM token e sincronizar com o backend (`PATCH /users/me/fcm-token`).
///   4. Escutar mensagens em foreground e mostrar banner via
///      `flutter_local_notifications`.
class FcmService {
  FcmService({FirebaseMessaging? messaging, FlutterLocalNotificationsPlugin? localPlugin})
      : _messaging = messaging ?? FirebaseMessaging.instance,
        _local = localPlugin ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;

  /// Canal default exposto no AndroidManifest via
  /// `default_notification_channel_id`. Precisa existir antes do primeiro push.
  static const _androidChannel = AndroidNotificationChannel(
    'imoveis_high',
    'Alertas i-Móveis',
    description: 'Novas visitas, respostas de anúncios e mensagens.',
    importance: Importance.high,
  );

  bool _initialized = false;
  String? _cachedToken;

  /// Inicializa Firebase + local notifications + listeners. Idempotente.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Background handler DEVE ser registrado antes de qualquer outra listener.
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);

    await _setupLocalNotifications();

    // No iOS/web é necessário pedir permissão antes de receber pushs. Android
    // também pede, em 13+ via POST_NOTIFICATIONS.
    await _messaging.requestPermission();

    // Apresenta banner + badge quando app está em foreground (iOS).
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
  }

  Future<void> _setupLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // iOS omitido — foreground no iOS já é tratado pelo Firebase.
    );
    await _local.initialize(initSettings);

    // Cria o canal Android — no-op em outras plataformas.
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_androidChannel);
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Web: service worker já pode ter mostrado. Evitamos duplicar.
    if (kIsWeb) return;

    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  /// Lê o token atual e sincroniza com o backend. No-op se o token ainda
  /// não está disponível (ex: permissão negada).
  /// Retorna o token sincronizado ou `null`.
  Future<String?> registerTokenWithBackend(Dio dio) async {
    try {
      final token = kIsWeb
          ? await _messaging.getToken(vapidKey: _kWebVapidKey)
          : await _messaging.getToken();
      if (token == null || token.isEmpty) return null;
      await _patchFcmToken(dio, token);
      _cachedToken = token;

      // Se o token rotacionar enquanto o app está vivo, re-sincroniza.
      _messaging.onTokenRefresh.listen((newToken) {
        if (newToken == _cachedToken) return;
        _cachedToken = newToken;
        unawaited(_patchFcmToken(dio, newToken));
      });

      return token;
    } on Object catch (e, st) {
      debugPrint('[fcm] registerTokenWithBackend falhou: $e\n$st');
      return null;
    }
  }

  Future<void> _patchFcmToken(Dio dio, String token) async {
    await dio.patch<void>(
      '/users/me/fcm-token',
      data: {'fcmToken': token},
    );
  }
}
