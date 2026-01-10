import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minna_ai_n5/core/service/auth_service.dart';

final authInitProvider = FutureProvider<User>((ref) async {
  final authService = AuthService();
  return authService.ensureUser();
});
