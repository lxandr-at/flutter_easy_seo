import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

class FaqItem {
  final String question;
  final String answer;
  const FaqItem({required this.question, required this.answer});
}

class FaqBlock extends StatelessWidget {
  final String locale;
  final List<FaqItem> items;

  const FaqBlock({super.key, required this.locale, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(item.answer, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
      ],
    ).easySeoFaq(
      items: items
          .map((e) => EasySEOFaqItem(question: e.question, answer: e.answer))
          .toList(),
    );
  }
}
