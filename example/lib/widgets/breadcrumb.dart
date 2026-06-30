import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import '../l10n/app_translations.dart';

class Breadcrumb extends StatelessWidget {
  final String locale;
  final List<String> labels;

  const Breadcrumb({super.key, required this.locale, required this.labels});

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);
    return _buildBreadcrumbList(items);
  }

  List<_BreadcrumbItem> _buildItems(BuildContext context) {
    final t = translations(locale);
    final items = <_BreadcrumbItem>[
      _BreadcrumbItem(label: t['nav.home']!, path: '/$locale'),
    ];
    for (var i = 0; i < labels.length; i++) {
      final subPath = labels.sublist(0, i + 1).join('/');
      final path = '/$locale/$subPath';
      items.add(_BreadcrumbItem(label: labels[i], path: path));
    }
    return items;
  }

  Widget _buildBreadcrumbList(List<_BreadcrumbItem> items) {
    final navItems = items
        .asMap()
        .entries
        .map((e) => SEONavItem(text: e.value.label, url: e.value.path))
        .toList();

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Text(' › ', style: TextStyle(color: Colors.grey)),
          Text(items[i].label, style: const TextStyle(fontSize: 13)),
        ],
      ],
    ).easySeoNav(
      isBreadcrumb: true,
      children: [
        SEONav(
          jsonLd: SEOHtmlJsonLd.breadcrumbListData(navItems),
        ),
      ],
    );
  }
}

class _BreadcrumbItem {
  final String label;
  final String path;
  const _BreadcrumbItem({required this.label, required this.path});
}
