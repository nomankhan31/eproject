import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? currentUser;

  bool isLoading = false;
  String? errorMessage;

  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.login(email, password);

      currentUser = await _service.getUser(result.user!.uid);

      if (currentUser == null) {
        throw Exception('User profile not found.');
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      rethrow;
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.register(name, email, password);

      currentUser = await _service.getUser(result.user!.uid);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    currentUser = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _service.resetPassword(email);
  }
}
