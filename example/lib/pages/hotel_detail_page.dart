import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_translations.dart';
import '../models/hotel.dart';
import '../providers/hotel_provider.dart';
import '../providers/reservation_provider.dart';
import '../routing/nav_adapter.dart';
import '../widgets/calendar.dart';
import '../widgets/review_list.dart';

class HotelDetailPage extends ConsumerStatefulWidget {
  final String locale;
  final String hotelId;
  const HotelDetailPage({super.key, required this.locale, required this.hotelId});

  @override
  ConsumerState<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends ConsumerState<HotelDetailPage> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  String _roomType = 'Standard';

  @override
  Widget build(BuildContext context) {
    final t = translations(widget.locale);
    final hotel = ref.watch(selectedHotelProvider(widget.hotelId));

    if (hotel == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t['hotel.noHotel']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(t['hotel.noHotelMsg']!),
          ],
        ),
      );
    }

    final stars = '★' * hotel.stars;
    final totalNights = _checkIn != null && _checkOut != null
        ? _checkOut!.difference(_checkIn!).inDays
        : 0;
    final totalPrice = totalNights * hotel.pricePerNight;

    final avgRating = hotel.reviews.isNotEmpty
        ? (hotel.reviews.map((r) => r.rating).reduce((a, b) => a + b) / hotel.reviews.length)
        : 0.0;

    final slug = hotel.id;
    final base = EasySEOManager.instance.getEffectiveCleanBaseUrl();
    final langs = EasySEOManager.instance.supportedLanguages;
    final headTags = <EasySEOHeadTag>[
      EasySEOLinkTag.canonical('$base/${widget.locale}/hotels/$slug'),
      ...langs.map((l) => EasySEOLinkTag.alternate(href: '$base/$l/hotels/$slug', lang: l)),
      EasySEOLinkTag.alternate(href: '$base/${langs.first}/hotels/$slug', lang: 'x-default'),
    ];

    final scrollable = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHotelSection(t, hotel, stars, avgRating),
          _buildAmenities(t),
          _buildBookingSection(t, hotel, totalNights, totalPrice),
          _buildReviews(t, hotel),
          const SizedBox(height: 32),
        ],
      ),
    ).easySeoMain(
      children: [],
    );
    final mq = MediaQuery.of(context);
    return EasySEOPage(
      rank: 1,
      title: hotel.name,
      description: hotel.description,
      headTags: headTags,
      includeGlobals: ['navigation_breadcrumb'],
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 900,
              maxHeight: mq.size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => RouterAdapter.of(context).pop(context),
                      tooltip: t['hotel.close']!,
                    ),
                  ],
                ),
                Flexible(child: scrollable),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelSection(Map<String, String> t, Hotel hotel, String stars, double avgRating) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hotel.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(stars, style: const TextStyle(color: Colors.amber, fontSize: 18)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(hotel.location, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(hotel.description),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              'Ab ${hotel.pricePerNight.toStringAsFixed(0)} € ${t['hotel.perNight']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    ).easySeoSection(
      children: [
        SEOH1(hotel.name, attributes: {'itemprop': 'name'}),
        SEOParagraph(hotel.description, attributes: {'itemprop': 'description'}),
      ],
      jsonLd: {
        '@type': 'Hotel',
        'name': hotel.name,
        'description': hotel.description,
        'location': hotel.location,
        'starRating': hotel.stars,
        'priceRange': hotel.pricePerNight.toStringAsFixed(0),
        if (hotel.reviews.isNotEmpty)
          'aggregateRating': {
            '@type': 'AggregateRating',
            'ratingValue': avgRating.toStringAsFixed(1),
            'reviewCount': hotel.reviews.length,
          },
        if (hotel.reviews.isNotEmpty)
          'review': hotel.reviews.map((r) => {
            '@type': 'Review',
            'author': {'@type': 'Person', 'name': r.author},
            'datePublished': r.date.toIso8601String(),
            'reviewBody': r.text,
            'reviewRating': {
              '@type': 'Rating',
              'ratingValue': r.rating,
            },
          }).toList(),
      },
    );
  }

  Widget _buildAmenities(Map<String, String> t) {
    final amenities = [
      t['hotel.amenities.wifi']!,
      t['hotel.amenities.pool']!,
      t['hotel.amenities.spa']!,
      t['hotel.amenities.parking']!,
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['hotel.amenities']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((a) => Chip(avatar: const Icon(Icons.check, size: 16), label: Text(a))).toList(),
          ),
        ],
      ),
    ).easySeoAside(
      children: amenities.map((a) => SEOParagraph(a)).toList(),
    );
  }

  Widget _buildBookingSection(Map<String, String> t, Hotel hotel, int totalNights, double totalPrice) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['hotel.chooseDates']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Calendar(
                  locale: widget.locale,
                  label: t['hotel.checkIn']!,
                  selectedDate: _checkIn,
                  onSelected: (d) => setState(() => _checkIn = d),
                  inline: true,
                  lastDate: _checkOut,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Calendar(
                  locale: widget.locale,
                  label: t['hotel.checkOut']!,
                  selectedDate: _checkOut,
                  onSelected: (d) => setState(() => _checkOut = d),
                  inline: true,
                  firstDate: _checkIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('${t['hotel.roomType']!}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
              DropdownButton<String>(
                value: _roomType,
                items: [
                  DropdownMenuItem(value: 'Standard', child: Text(t['hotel.room.standard']!)),
                  DropdownMenuItem(value: 'Superior', child: Text(t['hotel.room.superior']!)),
                  DropdownMenuItem(value: 'Deluxe', child: Text(t['hotel.room.deluxe']!)),
                ],
                onChanged: (v) => setState(() => _roomType = v!),
              ),
            ],
          ),
          if (totalNights > 0) ...[
            const SizedBox(height: 12),
            Text('$totalNights ${t['reservation.nights']}: ${totalPrice.toStringAsFixed(0)} €',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: totalNights > 0 ? () => _bookHotel(hotel, totalPrice) : null,
            icon: const Icon(Icons.book_online),
            label: Text(t['hotel.reserve']!),
          ),
        ],
      ),
    );
  }

  void _bookHotel(Hotel hotel, double totalPrice) {
    final reservation = Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hotelId: hotel.id,
      hotelName: hotel.name,
      roomType: _roomType,
      checkIn: _checkIn!,
      checkOut: _checkOut!,
      status: 'Bestätigt',
      totalPrice: totalPrice,
    );
    ref.read(reservationsProvider.notifier).addReservation(reservation);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${hotel.name} für ${totalPrice.toStringAsFixed(0)} € reserviert!')),
    );
    final nav = RouterAdapter.of(context);
    nav.pop(context);
    nav.go(context, '/${widget.locale}/reservations');
  }

  Widget _buildReviews(Map<String, String> t, Hotel hotel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['hotel.reviews']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ReviewList(locale: widget.locale, reviews: hotel.reviews, hotelName: hotel.name),
        ],
      ),
    );
  }
}
