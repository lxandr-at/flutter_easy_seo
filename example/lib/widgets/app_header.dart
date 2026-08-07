import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_translations.dart';
import '../routing/nav_adapter.dart';

const _pubDevUrl = 'https://pub.dev/packages/flutter_easy_seo';
const _pubDevBadgeUrl = 'https://img.shields.io/pub/v/flutter_easy_seo.svg?logo=dart&logoColor=ffffff&style=flat';

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
                _buildDemoLink(context, t),
                const SizedBox(height: 2),
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

  Widget _buildDemoLink(BuildContext context, Map<String, String> t) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(_pubDevUrl)),
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              t['app.demoLink']!,
              style: TextStyle(
                fontSize: 16,
                color: primary,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: primary,
              ),
            ),
          ),
          Icon(Icons.open_in_new, size: 14, color: primary),
        ],
      ),
    ).easySeoAnchor(
      path: _pubDevUrl,
      text: t['app.demoLink'],
      globalName: 'app-header-demo-link',
    );
  }
}
