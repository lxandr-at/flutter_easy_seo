import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_translations.dart';
import '../models/hotel.dart';
import '../providers/reservation_provider.dart';
import '../widgets/breadcrumb.dart';

class ReservationsPage extends ConsumerWidget {
  final String locale;
  const ReservationsPage({super.key, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = translations(locale);
    final reservations = ref.watch(reservationsProvider);

    final body = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Breadcrumb(locale: locale, labels: [t['nav.reservations']!]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t['reservation.title']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          if (reservations.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(t['reservation.empty']!)),
            )
          else
            ...reservations.map((r) => _buildReservationCard(t, r)),
          const SizedBox(height: 24),
        ],
      ),
    ).easySeoMain(
      children: [
        SEOH1(t['reservation.title']!),
        SEOSection(
          jsonLd: {
            '@type': 'ItemList',
            'itemListElement': reservations.map((r) {
              return {
                '@type': 'ListItem',
                'item': {
                  '@type': 'HotelReservation',
                  'reservationFor': {
                    '@type': 'Hotel',
                    'name': r.hotelName,
                  },
                  'checkinDate': r.checkIn.toIso8601String(),
                  'checkoutDate': r.checkOut.toIso8601String(),
                  'totalPrice': {
                    '@type': 'MonetaryAmount',
                    'value': r.totalPrice,
                    'currency': 'EUR',
                  },
                },
              };
            }).toList(),
          },
        ),
      ],
    );
    return EasySEOPage(
      title: t['reservation.title']!,
      child: body,
    );
  }

  Widget _buildReservationCard(Map<String, String> t, Reservation r) {
    final nights = r.checkOut.difference(r.checkIn).inDays;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(r.hotelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Chip(label: Text(r.status, style: const TextStyle(fontSize: 12, color: Colors.green))),
              ],
            ),
            const SizedBox(height: 4),
            Text(r.roomType, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t['reservation.checkIn']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('${r.checkIn.day}.${r.checkIn.month}.${r.checkIn.year}'),
                ]),
                const SizedBox(width: 24),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t['reservation.checkOut']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('${r.checkOut.day}.${r.checkOut.month}.${r.checkOut.year}'),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            Text('$nights ${t['reservation.nights']} – ${r.totalPrice.toStringAsFixed(0)} €',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ).easySeoArticle(
      children: [
        SEOH3(r.hotelName),
        SEOTime(text: t['reservation.checkIn'], dateTime: r.checkIn),
        SEOTime(text: t['reservation.checkOut'], dateTime: r.checkOut),
      ],
    );
  }
}
