import 'package:flutter/material.dart';
import 'package:gcoffee_r/controller/login.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:toastification/toastification.dart';
import 'auth/auth.dart';
import 'package:gcoffee_r/styles/textstyles.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final AuthService _authService = AuthService();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String message = '';
  bool isLoading = false;

  /// Fungsi registrasi akun
  Future<void> updatePassword() async {}

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            width: 550,
            height: 600,
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
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Reset Password', style: getTitleBlack(context)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Password memerlukan angka dan juga huruf kapital!',
                    style: TextStyle(
                      fontFamily: 'Oxanium',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const SizedBox(height: 70),
                  SizedBox(
                    width: 450,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        TextField(
                          controller: newPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Password baru',
                            labelStyle: TextStyle(
                              fontFamily: 'Oxanium',
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: false,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Masukkan Ulang Password',
                            labelStyle: TextStyle(
                              fontFamily: 'Oxanium',
                              fontSize: 16,
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
                    onPressed: isLoading ? null : updatePassword,
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 127, 88, 56),
                      fixedSize: Size(450, 40),
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
                              'Simpan',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Oxanium',
                                fontSize: 16,
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
