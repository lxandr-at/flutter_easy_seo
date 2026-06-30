import 'package:flutter/material.dart';
import '../l10n/app_translations.dart';
import 'app_footer.dart';
import 'app_header.dart';
import 'app_navigation.dart';

class ShellLayout extends StatelessWidget {
  final String locale;
  final Widget child;

  const ShellLayout({super.key, required this.locale, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = translations(locale);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(locale: locale, title: t['app.title']!),
            Expanded(child: child),
            AppFooter(locale: locale),
          ],
        ),
      ),
      bottomNavigationBar: AppNavigation(locale: locale),
    );
  }
}
