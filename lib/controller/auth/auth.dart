import 'package:flutter/foundation.dart'; // Import kDebugMode
import 'package:shared_preferences/shared_preferences.dart';
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
        try {
          // Insert fullName into the profiles table
          await _supabase.from('profiles').insert({
            'id': userId,
            'full_name': fullName,
            'username': username,
            'email': email,
            'roles': 'user',
          });
          return userId; // Only return userId if both auth and profile creation succeed
        } catch (dbError) {
          // If profile creation fails, delete the auth user
          if (kDebugMode) {
            print('Profile creation failed: ${dbError.toString()}');
          }
          await _supabase.auth.admin.deleteUser(userId);
          return null;
        }
      }
      return null; // Return null if user creation failed
    } catch (e) {
      if (kDebugMode) {
        print('sign up failed: ${e.toString()}');
      }
      return null; // Return null instead of error string
    }
  }

  //logout
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_role'); // Clear the user role
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

  // Add a method to check if user is admin
  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') == 'admin';
  }
}
