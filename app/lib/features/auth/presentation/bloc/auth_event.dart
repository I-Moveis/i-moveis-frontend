part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested({
    required String email,
    required String password,
  }) = LoginRequested;

  const factory AuthEvent.registerRequested({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) = RegisterRequested;

  const factory AuthEvent.logoutRequested() = LogoutRequested;

  const factory AuthEvent.socialLoginRequested({
    required SocialProvider provider,
  }) = SocialLoginRequested;

  const factory AuthEvent.checkSessionRequested() = CheckSessionRequested;

  const factory AuthEvent.demoLoginRequested({
    required DemoRole role,
  }) = DemoLoginRequested;
}
