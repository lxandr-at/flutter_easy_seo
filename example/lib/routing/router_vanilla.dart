import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/hotel_detail_page.dart';
import '../pages/hotel_list_page.dart';
import '../pages/landing_page.dart';
import '../pages/reservations_page.dart';
import '../widgets/shell_layout.dart';
import 'dialog_route_helper.dart';
import 'nav_adapter.dart';

class _VanillaRouterAdapter extends RouterAdapter {
  @override
  Widget buildApp(String initialLocale) {
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
            child: MaterialApp(
              title: 'Flutter Easy SEO – Demo (Navigator 1.0)',
              initialRoute: '/$initialLocale',
              onGenerateRoute: _onGenerateRoute,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }

  Route? _onGenerateRoute(RouteSettings settings) {
    final path = settings.name ?? '';
    final uri = Uri.tryParse(path);
    if (uri == null) return null;

    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    final locale = segments[0];
    final validLocale = ['de', 'en', 'fr'].contains(locale) ? locale : 'de';

    if (path == '/$validLocale') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => ShellLayout(
          locale: validLocale,
          child: LandingPage(locale: validLocale),
        ),
      );
    }

    if (path == '/$validLocale/hotels') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => ShellLayout(
          locale: validLocale,
          child: HotelListPage(locale: validLocale),
        ),
      );
    }

    if (path == '/$validLocale/reservations') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => ShellLayout(
          locale: validLocale,
          child: ReservationsPage(locale: validLocale),
        ),
      );
    }

    // /:locale/hotels/:hotelId  (dialog)
    final hotelMatch = RegExp('^/$validLocale/hotels/(.+)\$').firstMatch(path);
    if (hotelMatch != null) {
      final hotelId = hotelMatch.group(1)!;
      return buildDialogRoute(
        settings: settings,
        child: HotelDetailPage(locale: validLocale, hotelId: hotelId),
      );
    }

    return null;
  }

  @override
  void push(BuildContext context, String path) =>
      Navigator.pushNamed(context, path);

  @override
  void go(BuildContext context, String path) {
    final route = _onGenerateRoute(RouteSettings(name: path));
    if (route is ModalRoute && !route.opaque) {
      Navigator.pushNamed(context, path);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, path, (_) => false);
    }
  }

  @override
  void pop(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
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

final RouterAdapter routerAdapter = _VanillaRouterAdapter();
