import 'package:flutter/material.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/styles/textstyles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CheckEmail());
  }
}

class CheckEmail extends StatefulWidget {
  const CheckEmail({super.key});

  @override
  State<CheckEmail> createState() => _CheckEmailState();
}

class _CheckEmailState extends State<CheckEmail> {
  final TextEditingController emailController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = false;
  bool isEmailCorrect = false;
  bool isEmailInputEmpty = false;

  Future<void> _checkEmail() async {
    setState(() {
      isLoading = true;
      isEmailInputEmpty = emailController.text.isEmpty;
    });

    if (!isEmailInputEmpty) {
      try {
        // Cek apakah email terdaftar di database
        final response =
            await supabase
                .from('profiles')
                .select()
                .eq('email', emailController.text)
                .single();

        if (response != null) {
          // Kirim email reset password jika email ditemukan
          await supabase.auth.resetPasswordForEmail(
            emailController.text,
            redirectTo: 'https://gcoffee-r.netlify.app/#/resetpassword',
          );

          if (mounted) {
            showToast(
              context,
              title: 'Berhasil!',
              message: "Silahkan check email mu ya!",
              Type: ToastificationType.success,
            );
          }
        } else {
          setState(() {
            isEmailCorrect = true;
          });
        }
      } catch (error) {
        setState(() {
          isEmailCorrect = true;
        });
        if (mounted) {
          showToast(
            context,
            title: 'Gagal!',
            message: "Email tidak ditemukan",
            Type: ToastificationType.error,
          );
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
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
            padding: EdgeInsets.all(isMobile ? 15 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
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
                      'Recover password',
                      style: TextStyle(
                        fontFamily: 'Righteous',
                        fontSize: isMobile ? 28 : 36,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      'Silahkan masukkan email',
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
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Masukkan Email',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: isMobile ? 14 : 16,
                        ),
                        border: OutlineInputBorder(),
                        errorText:
                            isEmailInputEmpty
                                ? 'Email tidak boleh kosong'
                                : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (isEmailCorrect)
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (!isLoading) {
                        await _checkEmail();
                      }
                    },
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
                              color: Color.fromARGB(255, 210, 156, 100),
                            )
                            : const Text(
                              'Kirim',
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
