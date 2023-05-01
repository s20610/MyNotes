import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String email;
  final String? userId;

  const AuthUser(
      {required this.userId,
      required this.email,
      required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) => AuthUser(
      email: user.email!, isEmailVerified: user.emailVerified, userId: user.uid);
}
