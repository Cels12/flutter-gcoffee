import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:go_router/go_router.dart';

Widget buildSidebarAdmin({
  required BuildContext context,
  required bool isMenuOpen,
}) {
  return AnimatedPositioned(
    duration: Duration(milliseconds: 300),
    top: 0,
    left: isMenuOpen ? 0 : -200,
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
            TextButton(
              onPressed: () {
                context.goNamed(RouteNames.dashboard);
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
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                try {
                  context.goNamed(RouteNames.menupage);
                } catch (e) {
                  debugPrint('Nav error $e');
                }
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
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                try {
                  context.goNamed(RouteNames.addmeja);
                } catch (e) {
                  debugPrint('Nav error $e');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Icon(
                  Icons.table_restaurant_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                try {
                  context.goNamed(RouteNames.reviewpageadmin);
                } catch (e) {
                  debugPrint('Nav error $e');
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Icon(
                  Icons.reviews_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
