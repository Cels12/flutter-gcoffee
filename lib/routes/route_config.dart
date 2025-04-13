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
import 'package:gcoffee_r/pages/screens/landingpage.dart';
import 'package:gcoffee_r/routes/route_name.dart';
import 'package:go_router/go_router.dart';

class RouteConfig {
  static GoRouter returnRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: RouteNames.initial,
          pageBuilder: (context, state) {
            return const MaterialPage(child: Landingpage());
          },
        ),
        GoRoute(
          path: '/login',
          name: RouteNames.loginScreen,
          pageBuilder: (context, state) {
            return const MaterialPage(child: Loginpage());
          },
        ),
        GoRoute(
          path: '/signup',
          name: RouteNames.signUpScreen,
          pageBuilder: (context, state) {
            return const MaterialPage(child: SignUpPage());
          },
        ),
        GoRoute(
          path: '/meja',
          name: RouteNames.meja,
          pageBuilder: (context, state) {
            return MaterialPage(child: MejaInput());
          },
        ),
        GoRoute(
          path: '/homepage',
          name: RouteNames.homepageCust,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: homePageCust(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/dashboard',
          name: RouteNames.dashboard,
          pageBuilder: (context, state) {
            return MaterialPage(child: Dashboard());
          },
        ),
        GoRoute(
          path: '/recoverpassword',
          name: RouteNames.recoverpassword,
          pageBuilder: (context, state) {
            return MaterialPage(child: Enteremailforresetpassword());
          },
        ),
        GoRoute(
          path: '/reviewpage',
          name: RouteNames.reviewpage,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: ReviewsPage(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/favoritepage',
          name: RouteNames.favoritepage,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: PageFavorite(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/myreview',
          name: RouteNames.myreview,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: MyReviewPage(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/menupage',
          name: RouteNames.menupage,
          pageBuilder: (context, state) {
            return MaterialPage(child: MenuPage());
          },
        ),
        GoRoute(
          path: '/addmenu',
          name: RouteNames.addmenu,
          pageBuilder: (context, state) {
            return MaterialPage(child: AddMenu());
          },
        ),
        GoRoute(
          path: '/editmenu',
          name: RouteNames.editpage,
          pageBuilder: (context, state) {
            final Map<String, dynamic> params =
                state.extra as Map<String, dynamic>;
            return MaterialPage(
              child: EditMenu(
                id: params['id'],
                intialNamaMenu: params['initialNamaMenu'],
                initialHarga: params['initialHarga'],
                initialDesk: params['initialDesk'],
                initialGambar: params['initialGambar'],
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
