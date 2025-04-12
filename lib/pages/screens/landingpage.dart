import 'package:flutter/material.dart';
import 'package:gcoffee_r/pages/screens/desktoplandingpage2.dart';
import 'package:gcoffee_r/pages/screens/mobilelandingpage.dart';
import 'package:gcoffee_r/responsive/responsivelayout.dart';

class Landingpage extends StatelessWidget {
  const Landingpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsivelayout(
      mobile: Mobilelandingpage(),
      desktop: Desktoplandingpage2(),
    );
  }
}
