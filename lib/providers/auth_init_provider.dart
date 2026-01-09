import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/auth/auth_service.dart';

final authInitProvider = FutureProvider<User>((ref) async {
  final authService = AuthService();
  return authService.ensureUser();
});
