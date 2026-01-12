import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  
  final _googleSignIn = GoogleSignIn();

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

  /// ✨ Login bằng Google
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // 2. Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // 5. Create user document if not exists
        await _createUserIfNotExist(user, isGoogleUser: true);
      }

      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// ✨ Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// ✨ Link anonymous account to Google
  Future<User?> linkAnonymousToGoogle() async {
    try {
      final currentUser = _auth.currentUser;
      
      if (currentUser == null || !currentUser.isAnonymous) {
        throw Exception('No anonymous user to link');
      }

      // 1. Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }

      // 2. Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Link credentials
      final userCredential = await currentUser.linkWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // 5. Update user document with Google info
        await _updateUserWithGoogleInfo(user);
      }

      return user;
    } catch (e) {
      print('Error linking anonymous to Google: $e');
      rethrow;
    }
  }

  Future<void> _createUserIfNotExist(User user, {bool isGoogleUser = false}) async {
    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'createdAt': FieldValue.serverTimestamp(),
        'streak': 0,
        'lastStudyDate': null,
        'premium': false,
        // Google user info
        if (isGoogleUser) ...{
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'provider': 'google',
        },
      });
    }
  }

  Future<void> _updateUserWithGoogleInfo(User user) async {
    final doc = _firestore.collection('users').doc(user.uid);
    
    await doc.update({
      'displayName': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'provider': 'google',
      'linkedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is anonymous
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}