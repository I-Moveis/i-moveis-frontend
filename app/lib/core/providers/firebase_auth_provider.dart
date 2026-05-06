import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared [FirebaseAuth] instance. Lives behind a provider so tests can swap
/// it out. Assumes `Firebase.initializeApp` ran at bootstrap (see `main.dart`);
/// se falhar, retorna null graciosamente para não quebrar a UI.
final firebaseAuthProvider = Provider<FirebaseAuth?>((_) {
  try {
    return FirebaseAuth.instance;
  } on Object catch (e) {
    debugPrint('[firebaseAuthProvider] Erro ao obter FirebaseAuth.instance: $e');
    return null;
  }
});
