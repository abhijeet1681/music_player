import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Admin login
  Future<User?> adminLogin(String email, String password) async {
    try {
      if (email == 'admin@gmail.com' && password == 'admin123') {
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return result.user;
      }
      return null;
    } catch (e) {
      print("Admin login error: $e");
      return null;
    }
  }

  // User registration
  Future<User?> registerUser(
      String email, String password, String firstName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await result.user?.updateDisplayName(firstName);
      return result.user;
    } catch (e) {
      print("Registration error: $e");
      return null;
    }
  }

  // User login
  Future<User?> userLogin(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth state changes
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
