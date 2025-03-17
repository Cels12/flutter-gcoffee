import 'package:flutter/material.dart';
import 'package:gcoffee_r/pages/desktoplandingpage2.dart';
import 'package:gcoffee_r/responsive/responsivelayout.dart';
import 'package:gcoffee_r/pages/mobilelandingpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsivelayout(
        mobile: Mobilelandingpage(),
        desktop: Desktoplandingpage2(),
      ),
    );
  }
}
