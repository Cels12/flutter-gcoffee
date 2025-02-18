import 'package:flutter/material.dart';

class Landingpage extends StatelessWidget {
  List<Widget> pageChildren(double width) {
    return <Widget>[
      SizedBox(
        width: width,
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
              color: Color.fromARGB(255, 84, 47, 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              onPressed: () {
                debugPrint('Tombol ditekan');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Text(
                  'Pesan sekarang',
                  style: TextStyle(fontFamily: 'Oxanium', color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      // Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Transform.rotate(
          angle: -8 * 3.141592653589793 / 180, // 8 degrees in radians
          child: Image.asset('img/kopi.png', width: 700, height: 572),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pageChildren(constraints.biggest.width / 2),
          );
        } else {
          return Column(children: pageChildren(constraints.biggest.width));
        }
      },
    );
  }
}
