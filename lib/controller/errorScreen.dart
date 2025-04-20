import 'package:flutter/material.dart';

class Errorscreen extends StatelessWidget {
  const Errorscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(color: Colors.black45, child: Text('Error screen')),
      ),
    );
  }
}
