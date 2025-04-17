import 'package:flutter/material.dart';
import 'package:gcoffee_r/controller/auth/auth.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget buildProfileDropdown({
  required BuildContext context,
  required bool isProfileOpen,
  required double top,
  required double right,
}) {
  final supabase = Supabase.instance.client;
  return AnimatedPositioned(
    duration: const Duration(microseconds: 300),
    top: isProfileOpen ? top : -200,
    right: right,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 200,
        height: 100,
        color: const Color.fromARGB(255, 210, 156, 108),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            supabase.auth.currentUser != null
                ? Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: TextButton(
                    onPressed: () async {
                      // Reset nomor meja/kode meja
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('nomor_meja');
                      await prefs.remove('id_meja');

                      // Logout user
                      final authService = AuthService();
                      await authService.signOut();

                      if (context.mounted) {
                        context.goNamed(RouteNames.meja);
                      }
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () async {
                          if (context.mounted) {
                            context.goNamed(RouteNames.loginScreen);
                          }
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          if (context.mounted) {
                            context.goNamed(RouteNames.signUpScreen);
                          }
                        },
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    ),
  );
}

Widget buildProfileButton({
  required BuildContext context,
  required Function() onPressed,
  required bool isMobile,
}) {
  return Positioned(
    right: 30,
    top: 20,
    child: IconButton(
      onPressed: onPressed,
      icon: HeroIcon(
        HeroIcons.user,
        size: isMobile ? 30 : 40,
        color: Colors.grey,
      ),
    ),
  );
}
