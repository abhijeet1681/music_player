import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Music Player', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/user');
              },
              child: const Text('Enter as User'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Different color for admin
              ),
              child: const Text('Enter as Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
