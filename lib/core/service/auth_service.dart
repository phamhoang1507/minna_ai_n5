import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<User> ensureUser() async {
    User? user = _auth.currentUser;

    if (user == null) {
      final credential = await _auth.signInAnonymously();
      user = credential.user!;
      await _createUserIfNotExist(user);
    } else {
      await _createUserIfNotExist(user);
    }

    return user;
  }

  Future<void> _createUserIfNotExist(User user) async {
    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'createdAt': FieldValue.serverTimestamp(),
        'streak': 0,
        'lastStudyDate': null,
        'premium': false,
      });
    }
  }
}
