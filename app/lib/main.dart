import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('Flutter render error: ${details.exception}');
      };

      runApp(
        const ProviderScope(
          child: MyApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}
