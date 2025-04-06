import 'package:flutter/material.dart';
import 'package:gcoffee_r/pages/customer/meja.dart';
import 'package:gcoffee_r/pages/login.dart';
import 'package:gcoffee_r/pages/signup.dart';
import 'package:gcoffee_r/styles/textstyles.dart';

class Desktoplandingpage2 extends StatelessWidget {
  const Desktoplandingpage2({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.5;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromRGBO(141, 58, 4, 1.0),
              Color.fromRGBO(39, 16, 1, 1.0),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('GCoffee', style: getTitleWhite(context)),
                  Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const mejaInput(),
                            ),
                          );
                        },
                        child: Text('Pesan Kopi', style: getDescWhite(context)),
                      ),
                      const SizedBox(width: 30),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: Text('Daftar', style: getDescWhite(context)),
                      ),
                      const SizedBox(width: 30),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Loginpage(),
                            ),
                          );
                        },
                        child: Text('Login', style: getDescWhite(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 180,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: screenWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Kopi hangat di pagi hari',
                            style: TextStyle(
                              fontFamily: 'Righteous',
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 45,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'GCoffee hadir untuk memudahkan kamu dalam memesan kopi.',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Oxanium',
                                fontSize: 32,
                              ),
                            ),
                          ),
                          MaterialButton(
                            color: const Color.fromARGB(255, 84, 47, 17),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const mejaInput(),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 40,
                              ),
                              child: Text(
                                'Pesan sekarang',
                                style: TextStyle(
                                  fontFamily: 'Oxanium',
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Transform.rotate(
                          angle:
                              -8 *
                              3.141592653589793 /
                              180, // 8 degrees in radians
                          child: Image.asset('img/kopi.png'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
