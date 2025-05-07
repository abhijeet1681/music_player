import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'user_home_screen.dart';
import 'admin_home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    return StreamBuilder<User?>(
      stream: _auth.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;

          if (user == null) {
            return const LoginScreen();
          }

          // Check if user is admin (in a real app, you'd check a custom claim)
          if (user.email == 'admin@gmail.com') {
            return const AdminHomeScreen();
          } else {
            return const UserHomeScreen();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
