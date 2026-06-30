import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

class RawSeoDemo extends StatelessWidget {
  const RawSeoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'SEOHtml / SEOSpan / SEOTime composition demo',
        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
      ),
    ).easySeoHtml(
      children: [
        const SEOH3('Raw SEO Composition'),
        const SEOSpan('This text uses SEOSpan directly in the generated HTML.'),
        SEOTime(text: 'Published', dateTime: DateTime(2026, 6, 28)),
        const SEOParagraph('Paragraph built from SEOHtml subclasses.'),
        SEODiv(
          content: null,
          children: [
            const SEOSpan('Nested SEOSpan inside SEODiv'),
            SEODiv(
              jsonLd: {
                '@type': 'CreativeWork',
                'name': 'SEO Demo Example',
              },
              children: const [
                SEOSpan('Demo'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
