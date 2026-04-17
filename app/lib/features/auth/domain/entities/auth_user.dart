class AuthUser {

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isOwner = false,
  });
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool isOwner;
}
