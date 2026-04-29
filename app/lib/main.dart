import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'features/search/data/providers/data_providers.dart';
import 'features/search/domain/usecases/search_properties_usecase.dart';

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

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPrefs),
            propertyRepositoryProvider.overrideWith((ref) => ref.watch(dataPropertyRepositoryProvider)),
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
