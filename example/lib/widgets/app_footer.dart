import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import '../l10n/app_translations.dart';

class AppFooter extends StatelessWidget {
  final String locale;

  const AppFooter({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    final t = translations(locale);
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade900,
      child: Text(
        t['common.copyright']!,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    ).easySeoFooter(
      globalName: 'app-footer',
    );
  }
}
