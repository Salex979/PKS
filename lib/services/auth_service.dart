import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthService() {
    // Слушаем изменения состояния авторизации
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      _currentUser = AppUser.fromFirebaseUser(firebaseUser);
      notifyListeners();
    });
  }

  // Регистрация с email и паролем
  Future<void> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Обновляем displayName
      await userCredential.user?.updateDisplayName(displayName);
      
    } catch (e) {
      print('Ошибка регистрации: $e');
      rethrow;
    }
  }

  // Вход с email и паролем
  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Ошибка входа: $e');
      rethrow;
    }
  }

  // Выход
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Сброс пароля
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}