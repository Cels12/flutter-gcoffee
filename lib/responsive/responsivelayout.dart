import 'package:flutter/material.dart';

class Responsivelayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const Responsivelayout({
    super.key,
    required this.mobile,
    required this.desktop,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
