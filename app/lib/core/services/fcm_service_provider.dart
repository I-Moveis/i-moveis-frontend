import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import 'fcm_service.dart';

final fcmServiceProvider = Provider<FcmService?>((ref) {
  if (kUseMockAuth) return null;
  try {
    return FcmService(messaging: FirebaseMessaging.instance);
  } on Object catch (e) {
    debugPrint('[fcmServiceProvider] Erro ao obter FirebaseMessaging.instance: $e');
    return null;
  }
});
