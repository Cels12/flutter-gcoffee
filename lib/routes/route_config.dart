import 'package:flutter/material.dart';
import 'package:gcoffee_r/controller/enterEmailForResetPassword.dart';
import 'package:gcoffee_r/controller/errorScreen.dart';
import 'package:gcoffee_r/controller/login.dart';
import 'package:gcoffee_r/controller/signup.dart';
import 'package:gcoffee_r/controller/updatePassword.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gcoffee_r/styles/notification_styles.dart';
import 'package:toastification/toastification.dart';

class RouteConfig {
  static Future<bool> _isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('user_role');
    return userRole == 'admin';
  }

  static Future<String?> _guardedRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getString('user_role') == 'admin';

    // List of admin-only paths
    final adminPaths = [
      '/admin/dashboard',
      '/admin/menupage',
      '/admin/addmenu',
      '/admin/editmenu',
    ];

    // Check if trying to access admin routes
    if (adminPaths.any((path) => state.matchedLocation.startsWith(path))) {
      if (!isAdmin) {
        // Show unauthorized toast
        if (context.mounted) {
          showToast(
            context,
            title: 'Akses Ditolak',
            message: 'Anda tidak memiliki akses ke halaman ini',
            Type: ToastificationType.error,
          );
        }
        return '/login';
      }
    }

    // Public paths that don't need any checks
    if (state.matchedLocation == '/' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/recoverpassword') {
      return null;
    }

    // Handle customer routes
    if (state.matchedLocation.startsWith('/customer')) {
      final storedMeja = prefs.getString('id_meja');
      if (storedMeja == null) {
        return '/customer/meja';
      }
    }

    return null;
  }

  static GoRouter returnRouter() {
    return GoRouter(
      initialLocation: '/',
      redirect: _guardedRedirect,
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
          path: '/customer/meja',
          name: RouteNames.meja,
          pageBuilder: (context, state) {
            return MaterialPage(child: MejaInput());
          },
        ),
        GoRoute(
          path: '/customer/homepage',
          name: RouteNames.homepageCust,
          pageBuilder: (context, state) {
            // Handle both direct navigation and stored meja
            String idMeja;
            if (state.extra != null) {
              idMeja = state.extra as String;
            } else {
              final prefs = SharedPreferences.getInstance();
              idMeja =
                  prefs.toString(); // This will be handled by the page itself
            }
            return MaterialPage(child: homePageCust(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/admin/dashboard',
          name: RouteNames.dashboard,
          pageBuilder: (context, state) {
            return MaterialPage(child: Dashboard());
          },
        ),
        GoRoute(
          path: '/recoverpassword',
          name: RouteNames.recoverpassword,
          pageBuilder: (context, state) {
            return MaterialPage(child: EnterEmailForResetPassword());
          },
        ),
        GoRoute(
          path: '/updatepassword',
          name: RouteNames.updatepassword,
          pageBuilder: (context, state) {
            return MaterialPage(child: ResetPassword());
          },
        ),
        GoRoute(
          path: '/customer/reviewpage',
          name: RouteNames.reviewpage,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: ReviewsPage(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/customer/favoritepage',
          name: RouteNames.favoritepage,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: PageFavorite(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/customer/myreview',
          name: RouteNames.myreview,
          pageBuilder: (context, state) {
            final idMeja = state.extra as String;
            return MaterialPage(child: MyReviewPage(idMeja: idMeja));
          },
        ),
        GoRoute(
          path: '/admin/menupage',
          name: RouteNames.menupage,
          pageBuilder: (context, state) {
            return MaterialPage(child: MenuPage());
          },
        ),
        GoRoute(
          path: '/admin/addmenu',
          name: RouteNames.addmenu,
          pageBuilder: (context, state) {
            return MaterialPage(child: AddMenu());
          },
        ),
        GoRoute(
          path: '/admin/editmenu',
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
      errorBuilder: (context, state) => const Errorscreen(),
    );
  }
}
