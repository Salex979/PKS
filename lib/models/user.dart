import 'package:firebase_auth/firebase_auth.dart' as com;

class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  // Пустой пользователь
  static const empty = AppUser(id: '', email: '');

  // Проверка на пустоту
  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  // Создание из Firebase User
  factory AppUser.fromFirebaseUser(com.User? firebaseUser) {
    if (firebaseUser == null) return empty;
    
    return AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }
}

