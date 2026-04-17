import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_state.dart';

const _kOnboardingKey = 'onboarding_completed';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_kOnboardingKey) ?? false;
    emit(completed ? OnboardingState.completed : OnboardingState.pending);
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingKey, true);
    emit(OnboardingState.completed);
  }
}
