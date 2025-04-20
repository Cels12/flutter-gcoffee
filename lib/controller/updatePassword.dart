import 'package:flutter/material.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/styles/textstyles.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:gcoffee_r/routes/route_name.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  bool isPasswordEmpty = false;
  bool isEmailFound = false;

  Future<void> updatePassword() async {
    setState(() {
      isPasswordEmpty =
          newPasswordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty;
    });

    if (!isPasswordEmpty) {
      if (newPasswordController.text == confirmPasswordController.text) {
        try {
          await supabase.auth.updateUser(
            UserAttributes(password: newPasswordController.text),
          );
          if (mounted) {
            showToast(
              context,
              title: 'Berhasil',
              message: 'Password berhasil diperbarui',
              Type: ToastificationType.success,
            );

            context.goNamed(RouteNames.loginScreen);
          }
        } catch (error) {
          if (mounted) {
            showToast(
              context,
              title: 'Gagal!',
              message: 'Gagal memperbarui password',
              Type: ToastificationType.error,
            );
          }
        }
      }
    } else {
      if (mounted) {
        showToast(
          context,
          title: 'Peringantan!',
          message: 'Password tidak sama!',
          Type: ToastificationType.warning,
        );
      }
    }
  }

  Future<void> _recoverSessionFromUrl() async {
    final uri = Uri.base;
    final accessToken = uri.queryParameters['access_token'];
    final type = uri.queryParameters['type'];

    if (accessToken != null && type == 'recovery') {
      try {
        final response = await supabase.auth.recoverSession(accessToken);
        if (response.user != null) {
          print('User authenticated for password reset');
        } else {
          showToast(
            context,
            title: 'Error',
            message: 'Link reset tidak valid',
            Type: ToastificationType.error,
          );
        }
      } catch (e) {
        showToast(
          context,
          title: 'Error',
          message: 'Gagal autentikasi: $e',
          Type: ToastificationType.error,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _recoverSessionFromUrl();
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
            padding: EdgeInsets.all(isMobile ? 15 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 50),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: isMobile ? 15 : 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Perbarui Password',
                      style: TextStyle(
                        fontFamily: 'Righteous',
                        fontSize: isMobile ? 28 : 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      "Silahkan masukkan passsword baru",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 40 : 70),
                  SizedBox(
                    width: isMobile ? screenWidth * 0.8 : 450,
                    child: TextField(
                      controller: newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Password baru',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: isMobile ? 14 : 16,
                        ),
                        border: OutlineInputBorder(),
                        errorText:
                            isPasswordEmpty
                                ? "Password tidak boleh kosong"
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: isMobile ? screenWidth * 0.8 : 450,
                    child: TextField(
                      controller: newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Masukkan kembali password baru',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: isMobile ? 14 : 16,
                        ),
                        border: OutlineInputBorder(),
                        errorText:
                            isPasswordEmpty
                                ? "Password tidak boleh kosong"
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isEmailFound)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Email tidak ditemukan',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Oxanium',
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      updatePassword();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 127, 88, 56),
                      fixedSize: Size(isMobile ? screenWidth * 0.8 : 450, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Perbarui',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Oxanium',
                        fontSize: 10,
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
