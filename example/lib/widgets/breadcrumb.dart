import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_translations.dart';
import '../providers/breadcrumb_provider.dart';
import '../routing/nav_adapter.dart';

class Breadcrumb extends ConsumerWidget {
  final String locale;

  const Breadcrumb({super.key, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = translations(locale);
    final segments = ref.watch(breadcrumbProvider);

    return Row(
      children: [
        GestureDetector(
          onTap: () => RouterAdapter.of(context).go(context, '/$locale'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(t['nav.home']!, style: const TextStyle(fontSize: 13)),
          ),
        ).easySeoNavAnchor(path: '/$locale', text: t['nav.home']!),
        for (var i = 0; i < segments.length; i++) ...[
          const Text(' › ', style: TextStyle(color: Colors.grey)),
          GestureDetector(
            onTap: () => RouterAdapter.of(context).go(
              context,
              '/$locale/${segments.sublist(0, i + 1).map((s) => s.slug).join('/')}',
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Text(segments[i].label, style: const TextStyle(fontSize: 13)),
            ),
          ).easySeoNavAnchor(
            path: '/$locale/${segments.sublist(0, i + 1).map((s) => s.slug).join('/')}',
            text: segments[i].label,
          ),
        ],
      ],
    ).easySeoNav(isBreadcrumb: true, globalName: "navigation_breadcrumb");
  }
}
