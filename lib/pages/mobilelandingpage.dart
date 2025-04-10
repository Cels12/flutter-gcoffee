import 'package:flutter/material.dart';
import 'package:gcoffee_r/pages/customer/homepage_cust.dart';
import 'package:gcoffee_r/pages/customer/meja.dart';
import 'package:gcoffee_r/pages/login.dart';
import 'package:gcoffee_r/pages/signup.dart';

class Mobilelandingpage extends StatefulWidget {
  Mobilelandingpage({super.key});

  @override
  State<Mobilelandingpage> createState() => _Mobilelandingpage();
}

class _Mobilelandingpage extends State<Mobilelandingpage> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   // primary: false,
      //   backgroundColor: const Color.fromARGB(255, 255, 0, 0),
      //   title: Text(
      //     'GCoffee',
      //     style: TextStyle(color: Colors.white, fontFamily: 'Righteous'),
      //   ),
      //   actions: [
      //     IconButton(
      //       iconSize: 35,
      //       color: Color.fromARGB(255, 210, 156, 108),
      //       icon: Icon(Icons.menu),
      //       onPressed: () {
      //         setState(() {
      //           _isMenuOpen = !_isMenuOpen;
      //         });
      //       },
      //     ),
      //   ],
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromRGBO(141, 58, 4, 1.0),
              Color.fromRGBO(39, 16, 1, 1.0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Fixed GCoffee Text
            Positioned(
              top: 15, // Adjust the vertical position
              left: 20, // Adjust the horizontal position
              child: Text(
                'GCoffee',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Righteous',
                ),
              ),
            ),

            Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Aligns children to the center
                children: [
                  const SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 120.0),
                    child: Container(
                      // Shadow for the image
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            spreadRadius: 0,
                            blurRadius: 150,
                            offset: Offset(0, 7), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Image.asset('img/kopi_cropped.png', width: 282),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 40)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50.0,
                    ), // Adjust the horizontal padding as needed
                    child: Text(
                      'Kopi hangat di pagi hari',
                      textAlign: TextAlign.left, // Aligns text to the left
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontFamily: 'Righteous',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50.0,
                    ), // Adjust the horizontal padding as needed
                    child: Text(
                      'GCoffee hadir untuk memudahkan kamu dalam memesan kopi.',
                      textAlign: TextAlign.left, // Aligns text to the left
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Oxanium',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: MaterialButton(
                      color: Color.fromARGB(255, 84, 47, 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MejaInput()),
                          (route) => false,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        child: Text(
                          'Pesan sekarang',
                          style: TextStyle(
                            fontFamily: 'Oxanium',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Sidebar menu
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: 0,
              right: _isMenuOpen ? 0 : -200, // Adjust the width as needed
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(20.0),
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 109),
                  width: 200,
                  height: MediaQuery.of(context).size.height,
                  color: Color.fromARGB(255, 84, 47, 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      ListTile(
                        title: Text(
                          'Pesan',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MejaInput(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Loginpage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Daftar',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 10, // Adjust the vertical position
              right: 10, // Adjust the horizontal position
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isMenuOpen = !_isMenuOpen;
                  });
                },
                icon: Icon(
                  Icons.menu,
                  size: 35,
                  color: Color.fromARGB(255, 210, 156, 108),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
