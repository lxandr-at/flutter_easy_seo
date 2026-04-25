import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';

import 'home_page.dart';
import 'services_page.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const EasySEO(
        enabled: true,
        title: 'Home | SaaS Platform',
        description: 'The best SaaS platform for modern businesses.',
        additionalTags: {
          'og:title': 'SaaS Platform - Home',
          'og:description': 'The best SaaS platform for modern businesses.',
          'twitter:card': 'summary_large_image',
        },
        child: HomePage(),
      ),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const EasySEO(
        enabled: true,
        title: 'Our Services | SaaS Platform',
        description: 'Explore our comprehensive suite of services.',
        additionalTags: {
          'og:title': 'SaaS Platform - Services',
          'og:description': 'Explore our comprehensive suite of services.',
          'twitter:card': 'summary_large_image',
        },
        child: ServicesPage(),
      ),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SaaS Platform',
      routerConfig: _router,
    );
  }
}