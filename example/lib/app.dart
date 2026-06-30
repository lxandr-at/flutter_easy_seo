import 'package:flutter/material.dart';
import 'routing/app_router.dart';

class App extends StatelessWidget {
  final String initialLocale;

  const App({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) => routerAdapter.buildApp(initialLocale);
}
