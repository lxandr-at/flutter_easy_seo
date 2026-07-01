import 'package:flutter/material.dart';
import '../models/hotel.dart';

class ReviewList extends StatelessWidget {
  final String locale;
  final List<Review> reviews;
  final String hotelName;

  const ReviewList({super.key, required this.locale, required this.reviews, required this.hotelName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...reviews.map((review) => _buildReview(review)),
      ],
    );
  }

  Widget _buildReview(Review review) {
    final dateStr = '${review.date.day}.${review.date.month}.${review.date.year}';
    final stars = '★' * review.rating;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(review.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(stars, style: const TextStyle(color: Colors.amber)),
              ],
            ),
            const SizedBox(height: 4),
            Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Text(review.text),
          ],
        ),
      ),
    );
  }
}
