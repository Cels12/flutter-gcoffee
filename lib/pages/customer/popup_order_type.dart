import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gcoffee_r/styles/textstyles.dart';

class PopUpOrderType extends StatefulWidget {
  final Function(String) onOrderTypeSelected;

  const PopUpOrderType({super.key, required this.onOrderTypeSelected});

  @override
  State<PopUpOrderType> createState() => _PopUpOrderTypeState();
}

class _PopUpOrderTypeState extends State<PopUpOrderType> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 84, 47, 17),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, size: 30, color: Colors.white),
                  ),
                ),

                Text(
                  'Minum disini atau take away?',
                  style: getTitleWhiteOx(context),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.onOrderTypeSelected('dine in');
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 250,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coffeedinein.svg',
                              width: 120,
                              height: 120,
                            ),
                            SizedBox(height: 20),
                            Text('Minum disini', style: getDescBlack2(context)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        widget.onOrderTypeSelected('takeaway');
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 250,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/coffeetakeaway.svg',
                              width: 120,
                              height: 120,
                            ),
                            SizedBox(height: 20),
                            Text('Take away', style: getDescBlack2(context)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
