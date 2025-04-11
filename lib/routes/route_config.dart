import 'package:flutter/material.dart';
import 'package:gcoffee_r/controller/enterEmailForResetPassword.dart';
import 'package:gcoffee_r/controller/errorScreen.dart';
import 'package:gcoffee_r/controller/login.dart';
import 'package:gcoffee_r/controller/signup.dart';
import 'package:gcoffee_r/pages/admin/add_menu.dart';
import 'package:gcoffee_r/pages/admin/dashboard.dart';
import 'package:gcoffee_r/pages/admin/edit_menu.dart';
import 'package:gcoffee_r/pages/admin/menupage.dart';
import 'package:gcoffee_r/pages/customer/MyReviewPage.dart';
import 'package:gcoffee_r/pages/customer/favoritepage.dart';
import 'package:gcoffee_r/pages/customer/homepage_cust.dart';
import 'package:gcoffee_r/pages/customer/meja.dart';
import 'package:gcoffee_r/pages/customer/reviews.dart';
import 'package:gcoffee_r/pages/desktoplandingpage2.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:go_router/go_router.dart';

class RouteConfig {
  static GoRouter returnRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: ROuteNames.initial,
          pageBuilder: (context, state) {
            return const MaterialPage(child: Desktoplandingpage2());
          },
        ),
        GoRoute(
          path: '/login',
          name: ROuteNames.loginScreen,
          pageBuilder: (context, state) {
            return const MaterialPage(child: Loginpage());
          },
        ),
        GoRoute(
          path: '/signup',
          name: ROuteNames.signUpScreen,
          pageBuilder: (context, state) {
            return const MaterialPage(child: SignUpPage());
          },
        ),
        GoRoute(
          path: '/meja',
          name: ROuteNames.meja,
          pageBuilder: (context, state) {
            return MaterialPage(child: MejaInput());
          },
        ),
        GoRoute(
          path: '/homepage',
          name: ROuteNames.homepageCust,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: homePageCust(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/dashboard',
          name: ROuteNames.dashboard,
          pageBuilder: (context, state) {
            return MaterialPage(child: Dashboard());
          },
        ),
        GoRoute(
          path: '/recoverpassword',
          name: ROuteNames.recoverpassword,
          pageBuilder: (context, state) {
            return MaterialPage(child: Enteremailforresetpassword());
          },
        ),
        GoRoute(
          path: '/reviewpage',
          name: ROuteNames.reviewpage,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: ReviewsPage(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/favoritepage',
          name: ROuteNames.favoritepage,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: PageFavorite(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/myreview',
          name: ROuteNames.myreview,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: MyReviewPage(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/menupage',
          name: ROuteNames.menupage,
          pageBuilder: (context, state) {
            return MaterialPage(child: MenuPage());
          },
        ),
        GoRoute(
          path: '/addmenu',
          name: ROuteNames.addmenu,
          pageBuilder: (context, state) {
            return MaterialPage(child: AddMenu());
          },
        ),
        GoRoute(
          path: '/editmenu',
          name: ROuteNames.editpage,
          pageBuilder: (context, state) {
            final id = state.extra as int;
            final initialNamaMenu = state.extra as String;
            final initialHarga = state.extra as String;
            final initialDesk = state.extra as String;
            final initialGambar = state.extra as String;
            return MaterialPage(
              child: EditMenu(
                id: id,
                intialNamaMenu: initialNamaMenu,
                initialHarga: initialHarga,
                initialDesk: initialDesk,
                initialGambar: initialGambar,
              ),
            );
          },
        ),
      ],
      errorPageBuilder: (context, state) {
        return MaterialPage(child: Errorscreen());
      },
    );
  }
}
