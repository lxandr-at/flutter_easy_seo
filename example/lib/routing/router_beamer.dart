import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/hotel_detail_page.dart';
import '../pages/hotel_list_page.dart';
import '../pages/landing_page.dart';
import '../pages/reservations_page.dart';
import '../widgets/shell_layout.dart';
import 'nav_adapter.dart';

class _AppBeamLocation extends BeamLocation<BeamState> {
  _AppBeamLocation(super.routeInformation, [super.beamParameters]);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final path = state.uri.path;
    final segments = state.uri.pathSegments;
    final locale = segments.isNotEmpty && ['de', 'en', 'fr'].contains(segments[0])
        ? segments[0]
        : 'de';

    final hotelMatch = RegExp('^/$locale/hotels/(.+)\$').firstMatch(path);
    if (hotelMatch != null) {
      return [
        BeamPage(
          key: ValueKey('shell-$locale-${_contentKey(path, locale)}'),
          child: ShellLayout(locale: locale, child: HotelListPage(locale: locale)),
        ),
        BeamPage(
          key: ValueKey('hotel-${hotelMatch.group(1)}'),
          opaque: false,
          routeBuilder: (context, settings, child) => PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            barrierColor: Colors.black54,
            settings: settings,
            pageBuilder: (_, __, ___) => child,
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
          child: HotelDetailPage(locale: locale, hotelId: hotelMatch.group(1)!),
        ),
      ];
    }

    return [
      BeamPage(
        key: ValueKey('shell-$locale-${_contentKey(path, locale)}'),
        child: ShellLayout(locale: locale, child: _buildContent(path, locale)),
      ),
    ];
  }

  Widget _buildContent(String path, String locale) {
    if (path == '/$locale') return LandingPage(locale: locale);
    if (path == '/$locale/hotels') return HotelListPage(locale: locale);
    if (path == '/$locale/reservations') return ReservationsPage(locale: locale);
    return LandingPage(locale: locale);
  }

  String _contentKey(String path, String locale) {
    if (path == '/$locale') return 'landing';
    if (path.startsWith('/$locale/hotels')) return 'hotels';
    if (path == '/$locale/reservations') return 'reservations';
    return 'landing';
  }

  @override
  List<Pattern> get pathPatterns => [
        '/:locale',
        '/:locale/hotels',
        '/:locale/hotels/:hotelId',
        '/:locale/reservations',
      ];
}

class _BeamerRouterAdapter extends RouterAdapter {
  late final BeamerDelegate _beamerDelegate;

  @override
  Widget buildApp(String initialLocale) {
    _beamerDelegate = BeamerDelegate(
      initialPath: '/$initialLocale',
      locationBuilder: (info, params) => _AppBeamLocation(info, params),
    );

    return ProviderScope(
      child: Builder(
        builder: (context) {
          EasySEOManager.instance.init(
            baseUrl: 'https://fluttereasyseo.lxandr.at/example',
            supportedLanguages: ['de', 'en', 'fr'],
            pages: ['/', '/hotels', '/hotels/:hotelId'],
            enableInteractiveMode: true,
            pathProvider: (context) => (_beamerDelegate.currentBeamLocation.state as BeamState).uri.toString(),
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
              title: 'Flutter Easy SEO – Demo (Beamer)',
              routerDelegate: _beamerDelegate,
              routeInformationParser: BeamerParser(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }

  @override
  void push(BuildContext context, String path) =>
      _beamerDelegate.beamToNamed(path);

  @override
  void go(BuildContext context, String path) =>
      _beamerDelegate.beamToNamed(path, replaceRouteInformation: true);

  @override
  void pop(BuildContext context) {
    final delegate = Beamer.of(context);
    if (delegate.canBeamBack) delegate.beamBack();
  }

  @override
  String getCurrentPath(BuildContext context) =>
      (_beamerDelegate.currentBeamLocation.state as BeamState).uri.toString();

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

final RouterAdapter routerAdapter = _BeamerRouterAdapter();
