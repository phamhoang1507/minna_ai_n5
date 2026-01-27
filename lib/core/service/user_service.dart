import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserService(this._firestore, this._auth);

  /// ===== READ =====
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUser() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).get();
  }

  /// ===== UPDATE =====
  Future<void> updateUser(Map<String, dynamic> data) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update(data);
  }
}
