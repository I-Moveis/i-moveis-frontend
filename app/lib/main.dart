import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/services/fcm_service.dart';
import 'core/services/fcm_service_provider.dart';
import 'features/search/data/providers/data_providers.dart';
import 'features/search/domain/usecases/search_properties_usecase.dart';
import 'firebase_options.dart';
import 'core/constants.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Hive
      await Hive.initFlutter();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('Flutter render error: ${details.exception}');
      };

      final sharedPrefs = await SharedPreferences.getInstance();

      // Firebase tem que ser inicializado ANTES de FcmService/FirebaseAuth
      // serem tocados — o construtor do FcmService acessa
      // FirebaseMessaging.instance via default arg, o que resolve o app
      // `[DEFAULT]` no momento da construção.
      var firebaseReady = false;
      // Initialize Firebase/FCM. Protected for mock builds or missing config.
      if (!kUseMockAuth) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          firebaseReady = true;
        } on Object catch (e, st) {
          debugPrint('[main] Firebase.initializeApp falhou: $e\n$st');
        }
      }

      FcmService? fcmService;
      if (firebaseReady) {
        fcmService = FcmService();
        try {
          await fcmService.initialize();
        } on Object catch (e, st) {
          debugPrint('[main] FCM init falhou: $e\n$st');
        }
      }

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            propertyRepositoryProvider.overrideWith((ref) => ref.watch(dataPropertyRepositoryProvider)),
            if (fcmService != null)
              fcmServiceProvider.overrideWithValue(fcmService),
          ],
          child: const MyApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}
