import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/hotel_detail_page.dart';
import '../pages/hotel_list_page.dart';
import '../pages/landing_page.dart';
import '../pages/reservations_page.dart';
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
            showHighlights: true,
            disableOnGenerate: true,
            enableLiveOutput: true,
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
      redirect: (context, state) {
        if (state.uri.pathSegments.isEmpty) return '/$initialLocale';
        return null;
      },
      routes: [
        GoRoute(
          path: '/:locale',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            // When sub-routes exist (e.g. /de/hotels, /de/hotels/123),
            // the landing page shrinks to nothing and the ShellRoute's
            // content fills the screen.
            if (state.uri.pathSegments.length > 1) return const SizedBox.shrink();
            final locale = _localeFromState(state);
            return _GoRouterShell(
              locale: locale,
              child: LandingPage(locale: locale, route: state.uri.path),
            );
          },
          routes: [
            ShellRoute(
              navigatorKey: _shellNavigatorKey,
              builder: (context, state, child) => _GoRouterShell(
                locale: _localeFromState(state),
                child: child,
              ),
              routes: [
                GoRoute(
                  path: 'hotels',
                  builder: (context, state) => HotelListPage(locale: _localeFromState(state), route: state.uri.path),
                ),
                GoRoute(
                  path: 'hotels/:hotelId',
                  builder: (context, state) => HotelListPage(locale: _localeFromState(state), route: state.uri.path),
                ),
                GoRoute(
                  path: 'reservations',
                  builder: (context, state) => ReservationsPage(locale: _localeFromState(state), route: state.uri.path),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/:locale/:path(.*)',
          builder: (context, state) => const Center(child: Text('Page not found!')),
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
    final path = getCurrentPath(context);
    if (RegExp(r'^/[^/]+/hotels/[^/]+$').hasMatch(path)) {
      go(context, path.replaceAll(RegExp(r'/[^/]+$'), ''));
      return;
    }
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

/// Shell builder that wraps [ShellLayout] and conditionally renders
/// the hotel detail overlay when `hotelId` is present in the path.
///
/// This avoids creating a separate GoRouter dialog route with `pageBuilder`,
/// which would introduce a second [PopScope] in the shell navigator and
/// cause the "Multiple widgets used the same GlobalKey" crash.
class _GoRouterShell extends StatelessWidget {
  final String locale;
  final Widget child;

  const _GoRouterShell({required this.locale, required this.child});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final hotelId = state.pathParameters['hotelId'];

    return PopScope(
      canPop: hotelId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/$locale/hotels');
      },
      child: Stack(
        children: [
          ShellLayout(locale: locale, child: child),
          if (hotelId != null)
            Positioned.fill(
              child: Material(
                color: Colors.black54,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/$locale/hotels'),
                      child: const SizedBox.expand(),
                    ),
                    Center(
                      child: Material(
                        type: MaterialType.canvas,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        elevation: 24,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: 900,
                          height: 700,
                          child: HotelDetailPage(locale: locale, hotelId: hotelId, route: state.uri.path),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final RouterAdapter routerAdapter = _GoRouterAdapter();
