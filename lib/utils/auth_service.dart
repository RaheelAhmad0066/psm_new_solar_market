import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static bool isAuthenticated() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}