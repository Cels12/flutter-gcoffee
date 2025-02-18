import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return const DeskstopNav();
        } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
          return const DeskstopNav();
        } else {
          return const MobileNav();
        }
      },
    );
  }
}

class DeskstopNav extends StatelessWidget {
  const DeskstopNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'GCoffee',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontFamily: 'Righteous',
              ),
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    debugPrint('Tentang Kami');
                  },
                  child: Text(
                    'Tentang Kami',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Oxanium',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                TextButton(
                  onPressed: () {
                    debugPrint('Login');
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Oxanium',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                TextButton(
                  onPressed: () {
                    debugPrint('Daftar');
                  },
                  child: Text(
                    'Daftar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Oxanium',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MobileNav extends StatelessWidget {
  const MobileNav({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
