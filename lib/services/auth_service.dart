import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> ensureCustomerAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-signed-in',
        message: 'No authenticated user found.',
      );
    }

    await _functions.httpsCallable('ensureCustomerAccount').call({
      'name': user.displayName,
      'email': user.email,
      'phone': user.phoneNumber,
    });

    // The callable sets the customer custom claim. Refresh the token so the
    // shared Firestore rules immediately recognize this user as a customer.
    await user.getIdToken(true);
  }

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

    await ensureCustomerAccount();
    return credential;
  }

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await ensureCustomerAccount();
    return credential;
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email.trim());
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
    if (phone != null) data['phone'] = phone.trim();

    await _firestore.collection('users').doc(user.uid).set(
      data,
      SetOptions(merge: true),
    );
  }
}
