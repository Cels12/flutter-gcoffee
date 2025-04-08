import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gcoffee_r/pages/admin/dashboard.dart';
import 'package:gcoffee_r/pages/customer/meja.dart';
import 'package:gcoffee_r/pages/signup.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:toastification/toastification.dart';
import '../auth/auth.dart';
import 'package:gcoffee_r/styles/textstyles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await dotenv.load(fileName: ".env");
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
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final AuthService _auth = AuthService();
  final TextEditingController emailcontrol = TextEditingController();
  final TextEditingController passwordcontrol = TextEditingController();
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

    final adminEmail = dotenv.env['ADMIN_EMAIL'];
    final adminPassword = dotenv.env['ADMIN_PASSWORD'];

    if (emailcontrol.text.trim() == adminEmail &&
        passwordcontrol.text.trim() == adminPassword) {
      setState(() {
        message = 'Login berhasil!';
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Dashboard();
          },
        ),
      );
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
      final response =
          await supabase
              .from('profiles')
              .select('id, roles, email, username')
              .or('username.eq.$input,email.eq.$input')
              .single();

      if (response == null || response.isEmpty) {
        showToast(
          context,
          title: 'Login gagal',
          message: 'Email, username atau password salah',
          Type: ToastificationType.error,
        );
        setState(() {
          isLoginFailed = true;
          isLoading = false;
        });
        return;
      }

      final role = response['roles'];
      final email = response['email'];
      final username = response['username'];

      // Attempt to log in with the retrieved user ID
      final hasil = await _auth.signIn(
        input.contains('@') ? input : response['email'],
        passwordcontrol.text.trim(),
      );

      if (hasil == null) {
        showToast(
          context,
          title: 'Login gagal',
          message: 'Email, username atau password salah',
          Type: ToastificationType.error,
        );
        setState(() {
          isLoginFailed = true;
          isLoading = false;
        });
      } else {
        showToast(
          context,
          title: 'Login berhasil',
          message: 'Selamat datang! $username',
          Type: ToastificationType.success,
        );
        setState(() {
          isLoading = false;
        });

        // Redirect based on role
        if (mounted) {
          if (role == 'user') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return mejaInput(); // Customer homepage
                },
              ),
            );
          }
        }
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
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 200),
                    child: Text(
                      'Masukkan detail akun anda',
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      'Selamat datang kembali!',
                      style: getTitleBlackOx(context),
                    ),
                  ),
                  SizedBox(height: 70),
                  SizedBox(
                    width: 450,
                    child: TextField(
                      controller: emailcontrol,
                      decoration: InputDecoration(
                        labelText: 'Alamat Email atau Username',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(),
                        errorText:
                            isEmailEmpty ? 'Email tidak boleh kosong' : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 450,
                    child: TextField(
                      controller: passwordcontrol,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(gapPadding: 10),
                        errorText:
                            isPasswordEmpty
                                ? 'Password tidak boleh kosong'
                                : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (isLoginFailed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Email atau Password salah',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Oxanium',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          debugPrint('Lupa password');
                        },
                        child: Text(
                          'Lupa Password?',
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.6),
                            fontFamily: 'Oxanium',
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : login,
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
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
                  const SizedBox(height: 20),
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
                    onPressed: () {
                      debugPrint('Masuk dengan google');
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
