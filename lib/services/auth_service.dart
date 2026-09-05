import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Account could not be created.',
      );
    }

    await user.updateDisplayName(name.trim());

    await _firestore.collection('users').doc(user.uid).set(
      {
        'uid': user.uid,
        'name': name.trim(),
        'email': user.email,
        'phone': phone?.trim(),
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return credential;
  }

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-signed-in',
        message: 'No authenticated user found.',
      );
    }

    return _firestore.collection('users').doc(user.uid).get();
  }

  static Future<void> updateUserProfile({
    String? name,
    String? phone,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-signed-in',
        message: 'No authenticated user found.',
      );
    }

    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null && name.trim().isNotEmpty) {
      data['name'] = name.trim();
      await user.updateDisplayName(name.trim());
    }

    if (phone != null) {
      data['phone'] = phone.trim();
    }

    await _firestore.collection('users').doc(user.uid).set(
      data,
      SetOptions(merge: true),
    );
  }
}