// pages/signup_page.dart
import 'package:flutter/material.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'auth/auth.dart';
import 'package:gcoffee_r/styles/textstyles.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  String message = '';
  bool isLoading = false;

  /// Fungsi registrasi akun
  Future<void> signUp() async {
    setState(() => isLoading = true);

    final result = await _authService.signUp(
      emailController.text.trim(),
      passwordController.text.trim(),
      usernameController.text.trim(),
      fullNameController.text.trim(),
    );

    if (result != null) {
      setState(() {
        message = result;
        isLoading = false;
        showToast(
          context,
          title: 'Berhasil!',
          message: 'Registrasi akun berhasil!',
          Type: ToastificationType.success,
        );
        context.goNamed(RouteNames.loginScreen);
      });
    } else {
      setState(() {
        message = "Registrasi gagal!";
        isLoading = false;
      });
      if (mounted) {
        showToast(
          context,
          title: 'Gagal',
          message: 'Registrasi akun gagal, mohon menunggu sebelum mencoba lagi',
          Type: ToastificationType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('GCoffee', style: getTitleWhite(context)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromRGBO(141, 58, 4, 1.0),
              Color.fromRGBO(39, 16, 1, 1.0),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: isMobile ? screenWidth * 0.9 : 550,
            height: isMobile ? screenHeight * 0.7 : 600,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 15 : 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 200),
                    child: Text(
                      'Masukkan data diri Anda',
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontSize: isMobile ? 17 : 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: isMobile ? 6 : 35.0),
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            fontSize: isMobile ? 25 : 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 40 : 70),
                  SizedBox(
                    width: isMobile ? screenWidth * 0.8 : 450,
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Alamat Email',
                            labelStyle: TextStyle(
                              fontFamily: 'Oxanium',
                              fontSize: isMobile ? 14 : 16,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: fullNameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',

                            labelStyle: TextStyle(
                              fontFamily: 'Oxanium',
                              fontSize: isMobile ? 14 : 16,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: false,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',

                            labelStyle: TextStyle(
                              fontFamily: 'Oxanium',
                              fontSize: isMobile ? 14 : 16,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: false,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontFamily: 'Oxanium',
                              fontSize: isMobile ? 14 : 16,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: isLoading ? null : signUp,
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 127, 88, 56),
                      fixedSize: Size(isMobile ? screenWidth * 0.8 : 450, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Daftar',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Oxanium',
                                fontSize: 16,
                              ),
                            ),
                  ),
                  TextButton(
                    onPressed: () => context.goNamed(RouteNames.loginScreen),
                    child: Text.rich(
                      TextSpan(
                        text: 'Sudah punya akun?',
                        style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.6),
                          fontFamily: 'Oxanium',
                          fontSize: isMobile ? 14 : 16,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' Login',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color.fromRGBO(0, 0, 0, 0.6),
                              fontFamily: 'Oxanium',
                              fontSize: isMobile ? 14 : 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
