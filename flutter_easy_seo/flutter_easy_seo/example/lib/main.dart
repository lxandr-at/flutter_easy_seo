import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';

import 'home_page.dart';
import 'services_page.dart';

void main() {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  EasySEOConfig.instance.init(
    enableFileOutput: false, // Generate files on every walk
    enableLiveOutput: kDebugMode, // Only inject to DOM during debugging
    baseUrl: "https://mysite.com",
  );
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => EasySEO(
        title: 'SaaS Platform - Home',
        description: 'The best SaaS platform for modern businesses.',
        headTags: [
          EasySEOTwitterTag.card(), // default type is 'summary_large_image'
        ],
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => EasySEO(
        title: 'Our Services | SaaS Platform',
        description: 'Explore our comprehensive suite of services.',
        headTags: [
          EasySEOTwitterTag.card(), // default type is 'summary_large_image'
        ],
        child: const ServicesPage(),
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
