import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Login
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Registration
  Future<UserCredential> register(
    String name,
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email.trim(),
      role: 'user',
    );

    await _db.collection('users').doc(credential.user!.uid).set(user.toMap());

    return credential;
  }

  // Get user information
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap(doc.id, doc.data()!);
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Auth state
  Stream<User?> get authState => _auth.authStateChanges();

  // Password reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
