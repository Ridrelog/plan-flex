import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/main_page.dart';
import '../repository/auth_repository.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF4FBF6),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF235347)),
            ),
          );
        }

        if (snapshot.hasData) {
          return const MainPage();
        }

        return const LoginPage();
      },
    );
  }
}
