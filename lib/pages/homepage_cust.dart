import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePageCust extends StatefulWidget {
  const HomePageCust({super.key});

  @override
  State<HomePageCust> createState() => _HomePageCustState();
}

class _HomePageCustState extends State<HomePageCust> {
  bool _isMenuOpen = false;
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background utama
          Container(
            color: Color.fromARGB(255, 247, 247, 247),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 50,
                  ),
                  child: Row(
                    children: <Widget>[
                      // Teks GCoffee yang bergeser mengikuti sidebar
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.only(
                          left: _isMenuOpen ? 50 : 20,
                        ), // Bergeser
                        child: Text(
                          'GCoffee',
                          style: TextStyle(
                            color: Color.fromARGB(255, 84, 47, 17),
                            fontSize: 32,
                            fontFamily: 'Righteous',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // card CRUD

          // Sidebar
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: 0,
            left: _isMenuOpen ? 0 : -200,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Container(
                width: 80,
                height: MediaQuery.of(context).size.height,
                color: Color.fromARGB(255, 84, 47, 17),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    //home
                    Tooltip(
                      message: 'Home',
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Placeholder(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SvgPicture.asset(
                            'assets/icons/home.svg',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    //show cart
                    Tooltip(
                      message: 'Show Cart',
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Placeholder(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Icon(
                            Icons.add_circle_outline_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Home',
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Placeholder(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SvgPicture.asset(
                            'assets/icons/home.svg',
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Show Menu',
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Placeholder(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Icon(
                            Icons.add_circle_outline_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Show Menu',
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Placeholder(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Icon(
                            Icons.add_circle_outline_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //sidebar
          Positioned(
            top: 12,
            left: 10,
            child: IconButton(
              iconSize: 40,
              color: Color.fromARGB(255, 210, 156, 108),
              onPressed: _toggleMenu,
              icon: Icon(Icons.menu),
            ),
          ),
          // Area di luar sidebar untuk menutup menu saat diklik
        ],
      ),
    );
  }
}
