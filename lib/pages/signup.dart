// pages/signup_page.dart
import 'package:flutter/material.dart';
import 'package:gcoffee_r/pages/login.dart';
import '../auth/auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';
  bool isLoading = false;

  /// Fungsi registrasi akun
  Future<void> signUp() async {
    setState(() => isLoading = true);

    final result = await _authService.signUp(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (result != null) {
      setState(() => message = result);
    } else {
      setState(() => message = "Registrasi berhasil! Periksa email Anda.");
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (message.isNotEmpty)
              Text(message, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: false,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : signUp,
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Daftar'),
            ),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Loginpage()),
                  ),
              child: const Text("Sudah punya akun? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
