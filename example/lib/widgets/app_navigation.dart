import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import '../routing/nav_adapter.dart';
import '../l10n/app_translations.dart';

class AppNavigation extends StatelessWidget {
  final String locale;

  const AppNavigation({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    final t = translations(locale);
    return BottomNavigationBar(
      currentIndex: _currentIndex(context),
      onTap: (index) => _onTap(context, index),
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: t['nav.home']!),
        BottomNavigationBarItem(icon: const Icon(Icons.hotel), label: t['nav.hotels']!),
        BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: t['reservation.title']!),
      ],
    ).easySeoNav(
      globalName: 'app-nav',
      children: [
        SEONav(
          jsonLd: SEOHtmlJsonLd.siteNavigationData([
            SEONavItem(text: t['nav.home']!, url: '/$locale'),
            SEONavItem(text: t['nav.hotels']!, url: '/$locale/hotels'),
            SEONavItem(text: t['reservation.title']!, url: '/$locale/reservations'),
          ]),
        ),
      ],
    );
  }

  int _currentIndex(BuildContext context) {
    try {
      final location = RouterAdapter.of(context).getCurrentPath(context);
      if (location.contains('/hotels')) return 1;
      if (location.contains('/reservations')) return 2;
    } catch (_) {}
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: RouterAdapter.of(context).go(context, '/$locale'); break;
      case 1: RouterAdapter.of(context).go(context, '/$locale/hotels'); break;
      case 2: RouterAdapter.of(context).go(context, '/$locale/reservations'); break;
    }
  }
}
