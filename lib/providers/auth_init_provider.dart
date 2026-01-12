// File: lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minna_ai_n5/core/service/auth_service.dart';

// ✅ Provider cho AuthService singleton
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ✅ Stream provider cho auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// ✅ Provider để ensure user (anonymous nếu chưa login)
final authInitProvider = FutureProvider<User>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.ensureUser();
});

// ✅ Provider kiểm tra user có phải anonymous không
final isAnonymousProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.isAnonymous ?? true,
    loading: () => true,
    error: (_, __) => true,
  );
});

// ✅ Provider lấy current user
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// ✅ Provider kiểm tra user đã login chưa
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
