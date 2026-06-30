import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_translations.dart';
import '../providers/hotel_provider.dart';
import '../widgets/breadcrumb.dart';
import '../widgets/hotel_card.dart';

class HotelListPage extends ConsumerWidget {
  final String locale;
  const HotelListPage({super.key, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = translations(locale);
    final hotels = ref.watch(hotelsProvider);

    final body = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Breadcrumb(locale: locale, labels: [t['nav.hotels']!], slugs: ['hotels']),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t['nav.hotels']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Column(
            children: hotels.map((hotel) => HotelCard(locale: locale, hotel: hotel)).toList(),
          ).easySeoList(),
          const SizedBox(height: 24),
        ],
      ),
    ).easySeoMain(
      children: [
        SEOH1(t['nav.hotels']!),
      ],
    );
    return EasySEOPage(
      rank: 0,
      title: t['nav.hotels']!,
      description: t['landing.hero.subtitle'],
      child: body,
    );
  }
}
