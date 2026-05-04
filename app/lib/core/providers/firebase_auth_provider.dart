import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared [FirebaseAuth] instance. Lives behind a provider so tests can swap
/// it out. Assumes `Firebase.initializeApp` ran at bootstrap (see `main.dart`);
/// if Firebase wasn't initialised, accessing [FirebaseAuth.instance] throws
/// at first use.
final firebaseAuthProvider = Provider<FirebaseAuth>((_) {
  return FirebaseAuth.instance;
});
