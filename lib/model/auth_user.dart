import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String email;
  final String id;
  final bool emailVerified;
  AuthUser({
    required this.email,
    required this.id,
    required this.emailVerified,
  });
  factory AuthUser.fromFirebase(User user) => AuthUser(
    email: user.email!,
    id: user.uid,
    emailVerified: user.emailVerified,
  );
}
