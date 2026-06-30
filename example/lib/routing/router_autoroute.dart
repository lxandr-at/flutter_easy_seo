import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auto_route/app_router.dart';
import 'nav_adapter.dart';

class _AutoRouteRouterAdapter extends RouterAdapter {
  late final AppRouter _appRouter;

  @override
  Widget buildApp(String initialLocale) {
    _appRouter = AppRouter();

    return ProviderScope(
      child: Builder(
        builder: (context) {
          EasySEOManager.instance.init(
            baseUrl: 'https://hotel-booking.example.com',
            supportedLanguages: ['de', 'en', 'fr'],
            pages: ['/', '/hotels', '/hotels/:hotelId', '/reservations'],
            enableInteractiveMode: true,
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
              title: 'Flutter Easy SEO – Demo (auto_route)',
              routerConfig: _appRouter.config(
                includePrefixMatches: true,
                deepLinkBuilder: (_) => DeepLink.path('/$initialLocale'),
              ),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }

  @override
  void push(BuildContext context, String path) =>
      context.router.pushNamed(path);

  @override
  void go(BuildContext context, String path) =>
      context.router.replaceNamed(path);

  @override
  void pop(BuildContext context) {
    final router = AutoRouter.of(context);
    if (router.canPop()) router.popForced();
  }

  @override
  String getCurrentPath(BuildContext context) {
    final route = ModalRoute.of(context);
    return route?.settings.name ?? '';
  }

  @override
  List<String> getPathSegments(BuildContext context) {
    final path = getCurrentPath(context);
    return path.split('/').where((s) => s.isNotEmpty).toList();
  }

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

final RouterAdapter routerAdapter = _AutoRouteRouterAdapter();
