import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/shared_preferences_provider.dart';

enum OnboardingStatus { pending, completed }

const _kOnboardingKey = 'onboarding_completed';

class OnboardingNotifier extends AsyncNotifier<OnboardingStatus> {
  @override
  Future<OnboardingStatus> build() async {
    final prefs = ref.watch(sharedPreferencesProvider);
    final completed = prefs.getBool(_kOnboardingKey) ?? false;
    return completed ? OnboardingStatus.completed : OnboardingStatus.pending;
  }

  Future<void> complete() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_kOnboardingKey, true);
    state = const AsyncData(OnboardingStatus.completed);
  }
}

final onboardingProvider =
    AsyncNotifierProvider<OnboardingNotifier, OnboardingStatus>(
  OnboardingNotifier.new,
);
