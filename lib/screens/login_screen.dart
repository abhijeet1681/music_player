import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isAdminLogin = false;

  // Form fields
  String _email = '';
  String _password = '';
  String _firstName = '';
  String _confirmPassword = '';

  // Error message
  String _errorMessage = '';

  void _toggleLogin() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = '';
    });
  }

  void _toggleAdminLogin() {
    setState(() {
      _isAdminLogin = !_isAdminLogin;
      _errorMessage = '';
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        User? user;
        if (_isAdminLogin) {
          user = await _auth.adminLogin(_email, _password);
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            setState(() {
              _errorMessage = 'Invalid admin credentials';
            });
          }
        } else if (_isLogin) {
          user = await _auth.userLogin(_email, _password);
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/user');
          } else {
            setState(() {
              _errorMessage = 'Invalid email or password';
            });
          }
        } else {
          if (_password != _confirmPassword) {
            setState(() {
              _errorMessage = 'Passwords do not match';
            });
            return;
          }

          user = await _auth.registerUser(_email, _password, _firstName);
          if (user != null) {
            Navigator.pushReplacementNamed(context, '/user');
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.music_note, size: 60, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      'Music Player',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    if (!_isAdminLogin && !_isLogin) ...[
                      TextFormField(
                        decoration:
                            _buildInputDecoration('First Name', Icons.person),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your name' : null,
                        onSaved: (value) => _firstName = value!,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      decoration: _buildInputDecoration('Email', Icons.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your email' : null,
                      onSaved: (value) => _email = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _buildInputDecoration('Password', Icons.lock),
                      obscureText: true,
                      validator: (value) => value!.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                      onSaved: (value) => _password = value!,
                    ),
                    if (!_isLogin && !_isAdminLogin) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: _buildInputDecoration(
                            'Confirm Password', Icons.lock_outline),
                        obscureText: true,
                        validator: (value) => value!.isEmpty
                            ? 'Please confirm your password'
                            : null,
                        onSaved: (value) => _confirmPassword = value!,
                      ),
                    ],
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          _isLogin ? 'Login' : 'Register',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _toggleLogin,
                      child: Text(
                        _isLogin
                            ? 'Need an account? Register'
                            : 'Already have an account? Login',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    if (!_isAdminLogin)
                      TextButton(
                        onPressed: _toggleAdminLogin,
                        child: const Text(
                          'Admin Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _toggleAdminLogin,
                        child: const Text(
                          'User Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
