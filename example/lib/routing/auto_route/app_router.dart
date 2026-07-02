import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
// ignore: unused_import — needed by auto_route code generator
import '../../pages/hotel_detail_page.dart';
import 'app_router.gr.dart';
// ignore: unused_import — needed by auto_route code generator
import 'auto_shell.dart';

Route<T> _buildDialogRoute<T>(BuildContext context, Widget child, AutoRoutePage<T> page) {
  return PageRouteBuilder<T>(
    settings: page,
    pageBuilder: (_, __, ___) => child,
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 200),
  );
}

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/:locale',
          page: AutoShellRoute.page,
          children: [
            AutoRoute(path: '', page: LandingRoute.page, initial: true),
            AutoRoute(path: 'hotels', page: HotelListRoute.page),
            AutoRoute(path: 'reservations', page: ReservationsRoute.page),
          ],
        ),
        CustomRoute(
          path: '/:locale/hotels/:hotelId',
          page: HotelDetailRoute.page,
          customRouteBuilder: _buildDialogRoute,
          opaque: false,
        ),
      ];
}
