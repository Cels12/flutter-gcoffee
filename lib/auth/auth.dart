import 'package:flutter/foundation.dart'; // Import kDebugMode
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //login pake email dan password
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        password: password,
        email: email,
      );
      return response.user?.id; // Return user ID on successful login
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('login failed: ${e.message}');
      }
      return null;
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user?.id; // Return user ID on successful sign-up
    } catch (e) {
      if (kDebugMode) {
        print('sign up failed: ${e.toString()}');
      }
      return e.toString();
    }
  }

  //logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('sign out failed: ${e.toString()}');
      }
    }
  }

  //check user login
  bool isLoggedIn() {
    return _supabase.auth.currentUser != null;
  }
}
