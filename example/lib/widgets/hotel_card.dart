import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import '../models/hotel.dart';
import '../routing/nav_adapter.dart';

class HotelCard extends StatelessWidget {
  final String locale;
  final Hotel hotel;

  const HotelCard({super.key, required this.locale, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final stars = '★' * hotel.stars;
    final priceText = '${hotel.pricePerNight.toStringAsFixed(0)} € / Nacht';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => RouterAdapter.of(context).go(context, '/$locale/hotels/${hotel.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              EasySEOImageWrapper(
                alt: hotel.name,
                child: Image.network(
                  'https://picsum.photos/seed/${hotel.id}/160/160',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(stars, style: const TextStyle(color: Colors.amber, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(hotel.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(priceText, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    ).easySeoListItem(
      children: [
        SEOH3(hotel.name, attributes: {'itemprop': 'name'}),
        SEOAnchor(
          path: '/$locale/hotels/${hotel.id}',
          content: hotel.name,
          attributes: {'itemprop': 'item'},
        ),
        SEOSpan(hotel.location),
        SEOSpan(hotel.pricePerNight.toStringAsFixed(0)),
      ],
    );
  }
}
