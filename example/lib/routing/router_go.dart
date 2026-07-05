import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/hotel_detail_page.dart';
import '../pages/hotel_list_page.dart';
import '../pages/landing_page.dart';
import '../pages/reservations_page.dart';
import '../widgets/dialog_page.dart';
import '../widgets/shell_layout.dart';
import 'nav_adapter.dart';

class _GoRouterAdapter extends RouterAdapter {
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  @override
  Widget buildApp(String initialLocale) {
    GoRouter.optionURLReflectsImperativeAPIs = true;
    final router = _createRouter(initialLocale);

    return ProviderScope(
      child: Builder(
        builder: (context) {
          EasySEOManager.instance.init(
            baseUrl: 'https://fluttereasyseo.lxandr.at/example',
            supportedLanguages: ['de', 'en', 'fr'],
            pages: ['/', '/hotels', '/hotels/:hotelId'],
            enableInteractiveMode: true,
            pathProvider: (context) => GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration.uri.toString(),
            headTags: [
              const SEOServiceInfo(
                serviceType: 'Hotel Reservation',
                providerName: 'Hotel Buchungsplattform',
                brandLogoUrl: '/logo.png',
                areasServed: ['DE', 'AT', 'CH', 'FR'],
              ),
            ],
          );

          return RouterAdapterScope(
            adapter: this,
            child: MaterialApp.router(
              title: 'Flutter Easy SEO – Demo (GoRouter)',
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(String initialLocale) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/$initialLocale',
      routes: [
        // 1. The Main Shell Route for normal pages sharing the ShellLayout
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => ShellLayout(locale: _localeFromState(state), child: child),
          routes: [
            GoRoute(
              path: '/:locale',
              builder: (context, state) => LandingPage(locale: _localeFromState(state)),
              routes: [
                GoRoute(
                  path: 'hotels',
                  builder: (context, state) => HotelListPage(locale: _localeFromState(state)),
                  routes: [
                    GoRoute(
                      path: ':hotelId',
                      //parentNavigatorKey: _shellNavigatorKey,
                      pageBuilder: (context, state) => DialogPage(
                        key: state.pageKey,
                        child: HotelDetailPage(
                          locale: _localeFromState(state),
                          hotelId: state.pathParameters['hotelId']!,
                        ),
                      ),
                    ),
                  ]
                ),
                GoRoute(
                  path: 'reservations',
                  builder: (context, state) => ReservationsPage(locale: _localeFromState(state)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _localeFromState(GoRouterState state) {
    final locale = state.pathParameters['locale'] ?? 'de';
    return ['de', 'en', 'fr'].contains(locale) ? locale : 'de';
  }

  @override
  void push(BuildContext context, String path) => context.push(path);

  @override
  void go(BuildContext context, String path) => context.go(path);

  @override
  void pop(BuildContext context) {
    if (context.canPop()) context.pop();
  }

  @override
  String getCurrentPath(BuildContext context) =>
      GoRouterState.of(context).uri.toString();

  @override
  List<String> getPathSegments(BuildContext context) =>
      GoRouterState.of(context).uri.pathSegments;

  @override
  String getLocale(BuildContext context) {
    final segs = getPathSegments(context);
    return segs.isNotEmpty ? segs.first : 'de';
  }

  @override
  String replaceLocale(BuildContext context, String newLocale) {
    final segs = getPathSegments(context);
    return '/${[newLocale, ...segs.skip(1)].join('/')}';
  }
}

final RouterAdapter routerAdapter = _GoRouterAdapter();
