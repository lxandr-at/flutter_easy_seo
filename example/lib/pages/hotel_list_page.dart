import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_translations.dart';
import '../models/hotel.dart';
import '../providers/breadcrumb_provider.dart';
import '../providers/hotel_provider.dart';
import '../widgets/breadcrumb.dart';
import '../widgets/hotel_card.dart';

@RoutePage()
class HotelListPage extends ConsumerStatefulWidget {
  final String locale;
  final String route;
  const HotelListPage({super.key, @PathParam.inherit('locale') required this.locale, this.route = ''});

  @override
  ConsumerState<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends ConsumerState<HotelListPage> {
  bool _breadcrumbSet = false;

  @override
  Widget build(BuildContext context) {
    final t = translations(widget.locale);
    final hotelsAsync = ref.watch(hotelsProvider);

    return hotelsAsync.when(
      data: (hotels) => _buildContent(t, hotels),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(Map<String, String> t, List<Hotel> hotels) {
    if (!_breadcrumbSet) {
      _breadcrumbSet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(breadcrumbProvider.notifier).set(
          [BreadcrumbSegment(label: t['nav.hotels']!, slug: 'hotels')],
        );
      });
    }

    final body = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Breadcrumb(locale: widget.locale),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t['nav.hotels']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Column(
            children: hotels.map((hotel) => HotelCard(locale: widget.locale, hotel: hotel)).toList(),
          ).easySeoList(),
          const SizedBox(height: 24),
        ],
      ),
    ).easySeoMain(
      children: [
        SEOH2(t['nav.hotels']!),
      ],
    );
    final route = widget.route.isNotEmpty ? widget.route : '/${widget.locale}/hotels';
    return EasySEOPage(
      key: ValueKey(route),
      rank: 0,
      title: t['demo.hotels.title']!,
      description: t['demo.hotels.description'],
      includeGlobals: ['app-header', 'app-nav', 'navigation_breadcrumb', 'app-footer'],
      whenDone: () async => await ref.read(hotelsProvider.future),
      child: body,
    );
  }
}
