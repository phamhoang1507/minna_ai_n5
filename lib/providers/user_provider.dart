import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minna_ai_n5/core/service/user_service.dart';

/// Provider cho UserService
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

/// Stream user realtime
final userStreamProvider =
    StreamProvider<DocumentSnapshot<Map<String, dynamic>>>((ref) {
  return ref.read(userServiceProvider).watchCurrentUser();
});

/// Get user 1 lần (non-realtime)
final userFutureProvider =
    FutureProvider<DocumentSnapshot<Map<String, dynamic>>>((ref) {
  return ref.read(userServiceProvider).getCurrentUser();
});
