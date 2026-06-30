import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import '../l10n/app_translations.dart';
import '../routing/nav_adapter.dart';

class AppHeader extends StatelessWidget {
  final String locale;
  final String title;

  const AppHeader({super.key, required this.locale, required this.title});

  @override
  Widget build(BuildContext context) {
    final t = translations(locale);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(t['landing.hero.subtitle']!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: locale,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              items: const [
                DropdownMenuItem(value: 'de', child: Text('DE')),
                DropdownMenuItem(value: 'en', child: Text('EN')),
                DropdownMenuItem(value: 'fr', child: Text('FR')),
              ],
              onChanged: (newLocale) {
                if (newLocale != null && newLocale != locale) {
                  final newPath = RouterAdapter.of(context).replaceLocale(context, newLocale);
                  RouterAdapter.of(context).go(context, newPath);
                }
              },
            ),
          ),
        ],
      ),
    ).easySeoHeader(
      h1: title,
      p: t['landing.hero.subtitle'],
      globalName: 'app-header',
    );
  }
}
