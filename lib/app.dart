import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'providers/movie_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MovieProvider(FirestoreService())),
      ],
      child: MaterialApp(
        title: 'MovieWatchlist',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final movieProvider = context.read<MovieProvider>();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Показываем индикатор загрузки при проверке состояния
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Если пользователь авторизован
        if (snapshot.hasData && authService.currentUser != null) {
          // Устанавливаем userId для movieProvider
          final userId = authService.currentUser!.id;
          if (userId.isNotEmpty) {
            // Используем Future.microtask для избежания ошибок при обновлении
            WidgetsBinding.instance.addPostFrameCallback((_) {
              movieProvider.setUserId(userId);
            });
          }
          
          return const HomeScreen();
        }
        
        // Если не авторизован - показываем экран входа
        return const LoginScreen();
      },
    );
  }
}