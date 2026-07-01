import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import '../l10n/app_translations.dart';

class Breadcrumb extends StatelessWidget {
  final String locale;
  final List<String> labels;
  final List<String> slugs;

  const Breadcrumb({
    super.key,
    required this.locale,
    required this.labels,
    required this.slugs,
  });

  @override
  Widget build(BuildContext context) {
    final t = translations(locale);

    return Row(
      children: [
        Text(t['nav.home']!, style: const TextStyle(fontSize: 13))
            .easySeoNavAnchor(path: '/$locale', text: t['nav.home']!),
        for (var i = 0; i < labels.length; i++) ...[
          const Text(' › ', style: TextStyle(color: Colors.grey)),
          Text(labels[i], style: const TextStyle(fontSize: 13))
              .easySeoNavAnchor(
            path: '/$locale/${slugs.sublist(0, i + 1).join('/')}',
            text: labels[i],
          ),
        ],
      ],
    ).easySeoNav(isBreadcrumb: true, globalName: "navigation_breadcrumb");
  }
}
