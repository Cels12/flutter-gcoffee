import 'package:flutter/material.dart';
import 'package:gcoffee_r/styles/textstyles.dart';

class Enteremailforresetpassword extends StatefulWidget {
  const Enteremailforresetpassword({super.key});

  @override
  State<Enteremailforresetpassword> createState() =>
      _EnteremailforresetpasswordState();
}

class _EnteremailforresetpasswordState
    extends State<Enteremailforresetpassword> {
  bool isLoading = false;
  bool isEmailCorrect = false;
  bool isEmailInputEmpty = false;
  final TextEditingController emailController = TextEditingController();
  Future<void> _checkEmail() async {
    setState(() {
      isLoading = true;
      isEmailInputEmpty = emailController.text.trim().isEmpty;
      isEmailCorrect = false;
    });

    if (isEmailInputEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {} catch (e) {}
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Pulihkan passwordmu',
                      style: TextStyle(fontFamily: 'Righteous', fontSize: 36),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      'Kamu akan menerima sebuah email untuk merubah passwordmu',
                      style: TextStyle(
                        fontFamily: 'Oxanium',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 70),
                  SizedBox(
                    width: 450,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontFamily: 'Oxanium',
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(),
                        errorText:
                            isEmailInputEmpty
                                ? 'Email tidak boleh kosong!'
                                : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : _checkEmail,
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
                              'Send',
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
