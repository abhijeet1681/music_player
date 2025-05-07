import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/user_home_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/login_screen.dart'; // You'll need to create this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Simple login screen
        '/user': (context) => const UserHomeScreen(),
        '/admin': (context) => const AdminHomeScreen(),
      },
    );
  }
}
