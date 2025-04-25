import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';

Widget buildSidebar({
  required BuildContext context,
  required bool isMenuOpen,
  required Function() toggleCart,
  required String idMeja,
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
        width: MediaQuery.of(context).size.width < 1200 ? 70 : 80,
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
                  context.go('/customer/homepage/$idMeja');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SvgPicture.asset(
                    'assets/icons/home.svg',
                    width: MediaQuery.of(context).size.width < 1200 ? 30 : 40,
                    height: MediaQuery.of(context).size.width < 1200 ? 30 : 40,
                  ),
                ),
              ),
            ),
            //show cart
            Tooltip(
              message: 'Show Cart',
              child: TextButton(
                onPressed: toggleCart,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: HeroIcon(
                    HeroIcons.shoppingCart,
                    size: MediaQuery.of(context).size.width < 1200 ? 30 : 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            //Favorit
            Tooltip(
              message: 'Favorit',
              child: TextButton(
                onPressed: () {
                  final supabase = Supabase.instance.client;
                  if (supabase.auth.currentUser != null) {
                    context.go('/customer/favoritepage/$idMeja');
                  } else {
                    showToast(
                      context,
                      title: "Harus Login",
                      message: 'Kamu harus login untuk mengakses favorit!',
                      Type: ToastificationType.warning,
                    );
                    context.goNamed(RouteNames.loginScreen);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: HeroIcon(
                    HeroIcons.bookmark,
                    size: MediaQuery.of(context).size.width < 1200 ? 30 : 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            //Reviews
            Tooltip(
              message: 'Reviews',
              child: TextButton(
                onPressed: () {
                  final supabase = Supabase.instance.client;
                  if (supabase.auth.currentUser != null) {
                    context.go('/customer/reviewpage/$idMeja');
                  } else {
                    showToast(
                      context,
                      title: "Harus Login",
                      message: 'Kamu harus login untuk mengakses favorit!',
                      Type: ToastificationType.warning,
                    );
                    context.goNamed(RouteNames.loginScreen);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Icon(
                    Icons.reviews_outlined,
                    size: MediaQuery.of(context).size.width < 1200 ? 30 : 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
