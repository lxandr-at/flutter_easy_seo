import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:go_router/go_router.dart';
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
        BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: t['nav.reservations']!),
      ],
    ).easySeoNav(
      globalName: 'app-nav',
      children: [
        SEONav(
          jsonLd: SEOHtmlJsonLd.siteNavigationData([
            SEONavItem(text: t['nav.home']!, url: '/$locale'),
            SEONavItem(text: t['nav.hotels']!, url: '/$locale/hotels'),
            SEONavItem(text: t['nav.reservations']!, url: '/$locale/reservations'),
          ]),
        ),
      ],
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;
    if (location.contains('/hotels')) return 1;
    if (location.contains('/reservations')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/$locale'); break;
      case 1: context.go('/$locale/hotels'); break;
      case 2: context.go('/$locale/reservations'); break;
    }
  }
}
