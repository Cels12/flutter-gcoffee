// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:gcoffee_r/styles/textstyles.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth/auth.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Loginpage());
  }
}

class Loginpage extends StatefulWidget {
  final String? idMeja;
  const Loginpage({super.key, this.idMeja});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final AuthService _auth = AuthService();
  final String ADMIN_EMAIL = 'admin@gmail.com';
  final String ADMIN_PASSWORD = 'admin123';
  final TextEditingController emailcontrol = TextEditingController();
  final TextEditingController passwordcontrol = TextEditingController();
  final supabase = Supabase.instance.client;
  String message = '';
  bool isLoading = false;
  bool isEmailEmpty = false;
  bool isPasswordEmpty = false;
  bool isLoginFailed = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      isEmailEmpty = emailcontrol.text.trim().isEmpty;
      isPasswordEmpty = passwordcontrol.text.trim().isEmpty;
      isLoginFailed = false;
    });

    if (isEmailEmpty || isPasswordEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final adminEmail = ADMIN_EMAIL;
    final adminPassword = ADMIN_PASSWORD;

    if (emailcontrol.text.trim() == adminEmail &&
        passwordcontrol.text.trim() == adminPassword) {
      // Set admin role in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'admin');

      setState(() {
        message = 'Login berhasil!';
        isLoading = false;
      });

      if (mounted) {
        showToast(
          context,
          title: 'Login berhasil',
          message: 'Selamat datang Admin!',
          Type: ToastificationType.success,
        );
        context.goNamed(RouteNames.dashboard);
      }
      return;
    } else if (emailcontrol.text.trim() == adminEmail ||
        passwordcontrol.text.trim() == adminPassword) {
      // Jika email admin benar tetapi password salah
      setState(() {
        isLoginFailed = true;
        isLoading = false;
      });
      return;
    } else {
      // Check if the input is a username or email
      final input = emailcontrol.text.trim();
      final SupabaseClient supabase = Supabase.instance.client;
      try {
        final response =
            await supabase
                .from('profiles')
                .select('id, roles, email, username')
                .or('username.eq.$input,email.eq.$input')
                .limit(1)
                .maybeSingle();

        if (response == null) {
          if (mounted) {
            showToast(
              context,
              title: 'Login gagal',
              message: 'Email, username atau password salah',
              Type: ToastificationType.error,
            );
          }

          setState(() {
            isLoginFailed = true;
            isLoading = false;
          });
          return;
        }

        final role = response['roles'];
        // ignore: unused_local_variable
        final email = response['email'];
        final username = response['username'];

        // Attempt to log in with the retrieved user ID
        final hasil = await _auth.signIn(
          input.contains('@') ? input : response['email'],
          passwordcontrol.text.trim(),
        );

        if (hasil == null) {
          if (mounted) {
            showToast(
              context,
              title: 'Login gagal',
              message: 'Email, username atau password salah',
              Type: ToastificationType.error,
            );
          }
          setState(() {
            isLoginFailed = true;
            isLoading = false;
          });
        } else {
          if (mounted) {
            showToast(
              context,
              title: 'Login berhasil',
              message: 'Selamat datang! $username',
              Type: ToastificationType.success,
            );
          }
          setState(() {
            isLoading = false;
          });

          // Redirect based on role
          if (mounted) {
            if (role == 'user') {
              // Redirect ke halaman meja untuk input nomor meja
              context.goNamed(RouteNames.meja);
            }
          }
        }
      } catch (e) {
        if (mounted) {
          showToast(
            context,
            title: 'Login gagal',
            message: 'Email, username atau password salah',
            Type: ToastificationType.error,
          );
        }

        setState(() {
          isLoginFailed = true;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _nativeGoogleSignIn() async {
    const webClientId =
        '530147739278-2uqg0pg89n1hald6n0qhrheh75q7stdn.apps.googleusercontent.com';
    const iosClientId = 'my-ios.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final authResponse = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user != null) {
        // Generate username dari display name
        String displayName =
            authResponse.user!.userMetadata?['full_name'] ?? '';
        String generatedUsername = displayName.toLowerCase().replaceAll(
          ' ',
          '_',
        );

        // Cek apakah username sudah ada
        int counter = 0;
        String finalUsername = generatedUsername;
        bool usernameExists;

        do {
          final response =
              await supabase
                  .from('profiles')
                  .select()
                  .eq('username', finalUsername)
                  .maybeSingle();

          usernameExists = response != null;
          if (usernameExists) {
            counter++;
            finalUsername = '${generatedUsername}_$counter';
          }
        } while (usernameExists);

        // Tambahkan user ke tabel profiles
        await supabase.from('profiles').upsert({
          'id': authResponse.user!.id,
          'email': authResponse.user!.email,
          'username': finalUsername,
          'full_name': displayName,
          'roles': 'user',
          'updated_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          showToast(
            context,
            title: 'Login berhasil',
            message: 'Selamat datang ${displayName}!',
            Type: ToastificationType.success,
          );

          context.goNamed(RouteNames.meja);
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          title: 'Login gagal',
          message: e.toString(),
          Type: ToastificationType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    emailcontrol.dispose();
    passwordcontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 1200;

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
                    padding: const EdgeInsets.only(right: 200),
                    child: Text(
                      'Masukkan detail akun anda',
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontSize: isMobile ? 15 : 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      'Selamat datang kembali!',
                      style: TextStyle(
                        fontFamily: 'Righteous',
                        fontSize: isMobile ? 28 : 36,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 40 : 70),
                  SizedBox(
                    width: isMobile ? screenWidth * 0.8 : 450,
                    child: TextField(
                      controller: emailcontrol,
                      decoration: InputDecoration(
                        labelText: 'Alamat Email atau Username',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: isMobile ? 14 : 16,
                        ),
                        border: OutlineInputBorder(),
                        errorText:
                            isEmailEmpty ? 'Email tidak boleh kosong' : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: isMobile ? screenWidth * 0.8 : 450,
                    child: TextField(
                      controller: passwordcontrol,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: isMobile ? 14 : 16,
                        ),
                        border: OutlineInputBorder(gapPadding: 10),
                        errorText:
                            isPasswordEmpty
                                ? 'Password tidak boleh kosong'
                                : null,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 3 : 10),
                  Padding(
                    padding: EdgeInsets.only(right: isMobile ? 2 : 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.goNamed(RouteNames.checkemail);
                        },
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.6),
                            fontFamily: 'Oxanium',
                            fontSize: isMobile ? 12 : 13,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 3 : 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : login,
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
                              'Masuk',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Oxanium',
                                fontSize: 16,
                              ),
                            ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.goNamed(RouteNames.signUpScreen);
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Tidak punya akun?',
                        style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.6),
                          fontFamily: 'Oxanium',
                          fontSize: 15,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' Daftar',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color.fromRGBO(0, 0, 0, 0.6),
                              fontFamily: 'Oxanium',
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 10 : 20),
                  Center(
                    child: SizedBox(
                      width: 445,
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(thickness: 1, color: Colors.black45),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'atau',
                              style: TextStyle(
                                color: Colors.black45,
                                fontFamily: 'Righteous',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(thickness: 1, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                        await _nativeGoogleSignIn();
                      } else {
                        try {
                          if (mounted) {
                            showToast(
                              context,
                              title: 'Info',
                              message: 'Memulai proses login Google...',
                              Type: ToastificationType.info,
                            );
                          }

                          final response = await supabase.auth.signInWithOAuth(
                            OAuthProvider.google,
                            redirectTo:
                                kIsWeb
                                    ? 'https://gcoffee-r.netlify.app/#/customer/meja'
                                    : 'https://gcoffee-r.netlify.app/#/customer/meja',
                            authScreenLaunchMode: LaunchMode.inAppWebView,
                          );

                          if (!response) {
                            if (mounted) {
                              showToast(
                                context,
                                title: 'Login Gagal',
                                message: 'Gagal memulai proses OAuth Google',
                                Type: ToastificationType.error,
                              );
                            }
                            return;
                          }

                          if (mounted) {
                            showToast(
                              context,
                              title: 'Info',
                              message: 'Menunggu autentikasi Google...',
                              Type: ToastificationType.info,
                            );
                          }

                          // Tunggu dan dengarkan perubahan auth state
                          late final StreamSubscription<AuthState> subscription;

                          subscription = supabase.auth.onAuthStateChange.listen(
                            (data) async {
                              if (data.event == AuthChangeEvent.signedIn &&
                                  data.session != null) {
                                subscription.cancel();

                                final user = data.session!.user;
                                if (mounted) {
                                  showToast(
                                    context,
                                    title: 'Info',
                                    message:
                                        'Login berhasil sebagai: ${user.email}',
                                    Type: ToastificationType.success,
                                  );
                                }

                                try {
                                  if (mounted) {
                                    showToast(
                                      context,
                                      title: 'Info',
                                      message: 'Memeriksa profil user...',
                                      Type: ToastificationType.info,
                                    );
                                  }

                                  final existingProfile =
                                      await supabase
                                          .from('profiles')
                                          .select()
                                          .eq('id', user.id)
                                          .maybeSingle();

                                  if (existingProfile == null) {
                                    if (mounted) {
                                      showToast(
                                        context,
                                        title: 'Info',
                                        message: 'Membuat profil baru...',
                                        Type: ToastificationType.info,
                                      );
                                    }

                                    String displayName =
                                        user.userMetadata?['full_name'] ?? '';
                                    if (displayName.isEmpty) {
                                      displayName =
                                          user.email?.split('@')[0] ?? 'User';
                                    }

                                    String baseUsername = displayName
                                        .toLowerCase()
                                        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
                                        .replaceAll(RegExp(r'_+'), '_')
                                        .replaceAll(RegExp(r'^_|_$'), '');

                                    String finalUsername = baseUsername;
                                    int counter = 0;

                                    while (true) {
                                      final usernameCheck =
                                          await supabase
                                              .from('profiles')
                                              .select()
                                              .eq('username', finalUsername)
                                              .maybeSingle();

                                      if (usernameCheck == null) break;

                                      counter++;
                                      finalUsername = '${baseUsername}$counter';
                                    }

                                    await supabase.from('profiles').insert({
                                      'id': user.id,
                                      'email': user.email,
                                      'username': finalUsername,
                                      'full_name': displayName,
                                      'roles': 'user',
                                      'updated_at':
                                          DateTime.now().toIso8601String(),
                                    });

                                    if (mounted) {
                                      showToast(
                                        context,
                                        title: 'Sukses',
                                        message:
                                            'Profil berhasil dibuat untuk $displayName',
                                        Type: ToastificationType.success,
                                      );
                                    }
                                  }

                                  // Tambahkan delay singkat sebelum navigasi
                                  await Future.delayed(
                                    Duration(milliseconds: 500),
                                  );

                                  if (mounted) {
                                    showToast(
                                      context,
                                      title: 'Info',
                                      message: 'Mengalihkan ke halaman meja...',
                                      Type: ToastificationType.info,
                                    );

                                    // Coba kedua cara navigasi
                                    try {
                                      context.go('/customer/meja');
                                    } catch (navError) {
                                      showToast(
                                        context,
                                        title: 'Error Navigasi',
                                        message:
                                            'Error: $navError, mencoba cara lain...',
                                        Type: ToastificationType.warning,
                                      );

                                      try {
                                        context.goNamed(RouteNames.meja);
                                      } catch (navError2) {
                                        showToast(
                                          context,
                                          title: 'Error Navigasi',
                                          message: 'Gagal navigasi: $navError2',
                                          Type: ToastificationType.error,
                                        );
                                      }
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    showToast(
                                      context,
                                      title: 'Error',
                                      message:
                                          'Error saat memproses profil: $e',
                                      Type: ToastificationType.error,
                                    );
                                  }
                                }
                              } else if (data.event ==
                                  AuthChangeEvent.signedOut) {
                                if (mounted) {
                                  showToast(
                                    context,
                                    title: 'Info',
                                    message: 'User signed out',
                                    Type: ToastificationType.warning,
                                  );
                                }
                              }
                            },
                            onError: (error) {
                              if (mounted) {
                                showToast(
                                  context,
                                  title: 'Error Auth State',
                                  message: 'Error: $error',
                                  Type: ToastificationType.error,
                                );
                              }
                            },
                          );
                        } catch (e) {
                          if (mounted) {
                            showToast(
                              context,
                              title: 'Error Login',
                              message: 'Error saat proses login: $e',
                              Type: ToastificationType.error,
                            );
                          }
                        }
                      }
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/google2.svg',
                      width: 20,
                      height: 20,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 210, 156, 100),
                      fixedSize: Size(450, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    label: Text(
                      'Masuk dengan Google',
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
