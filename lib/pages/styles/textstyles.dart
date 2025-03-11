import 'package:flutter/material.dart';

getDescWhite(BuildContext context) {
  return TextStyle(color: Colors.white, fontFamily: 'Oxanium', fontSize: 18);
}

getDescBlack(BuildContext context) {
  return TextStyle(color: Colors.black, fontFamily: 'Oxanium', fontSize: 18);
}

getDescChocoDesktop(BuildContext context) {
  return TextStyle(
    color: Color.fromRGBO(87, 47, 17, 255),
    fontFamily: 'Oxanium',
    fontSize: 36,
  );
}

getPriceChocoMobile(BuildContext context) {
  return TextStyle(
    color: Color.fromRGBO(87, 47, 17, 255),
    fontFamily: 'Oxanium',
    fontSize: 16,
  );
}

getTitleWhite(BuildContext context) {
  return TextStyle(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontFamily: 'Righteous',
    fontSize: 30,
  );
}

getTitleBlackOx(BuildContext context) {
  return TextStyle(
    color: Colors.black,
    fontFamily: 'Oxanium',
    fontSize: 38,
    fontWeight: FontWeight.bold,
  );
}
