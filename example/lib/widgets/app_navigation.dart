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
    return NavigationBar(
      selectedIndex: _currentIndex(context),
      onDestinationSelected: (index) => _onTap(context, index),
      destinations: [
        NavigationDestination(icon: const Icon(Icons.home), label: t['nav.home']!).easySeoNavAnchor(path: '/$locale', text: t['nav.home']!),
        NavigationDestination(icon: const Icon(Icons.hotel), label: t['nav.hotels']!).easySeoNavAnchor(path: '/$locale/hotels', text: t['nav.hotels']!),
        NavigationDestination(icon: const Icon(Icons.calendar_today), label: t['reservation.title']!),
      ],
    ).easySeo(globalName: 'app-nav');
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
