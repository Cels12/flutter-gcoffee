import 'package:flutter/foundation.dart'; // Import kDebugMode
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseClient get supabase => _supabase;

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

  Future<String?> signUp(
    String email,
    String password,
    String fullName,
    String username,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final userId = response.user?.id;

      if (userId != null) {
        // Insert fullName into the profiles table
        await _supabase.from('profiles').insert({
          'id': userId,
          'full_name': fullName,
          'username': username,
          'role': 'user',
        });
      }

      return userId; // Return user ID on successful sign-up
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
