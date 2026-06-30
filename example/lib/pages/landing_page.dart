import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import '../l10n/app_translations.dart';
import '../routing/nav_adapter.dart';
import '../widgets/breadcrumb.dart';
import '../widgets/faq_block.dart';
import '../widgets/raw_seo_demo.dart';

class LandingPage extends StatelessWidget {
  final String locale;
  const LandingPage({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    final t = translations(locale);
    final body = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Breadcrumb(locale: locale, labels: const [], slugs: const []),
          ),
          _buildHero(context, t),
          _buildFeatures(t),
          _buildFaq(t),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: RawSeoDemo(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ).easySeoMain(
      children: [
        SEOArticle(
          jsonLd: {
            '@type': 'WebPage',
            'name': t['app.title'],
            'description': t['landing.hero.subtitle'],
          },
        ),
      ],
    );
    return EasySEOPage(
      title: t['app.title']!,
      description: t['landing.hero.subtitle'],
      child: body,
    );
  }

  Widget _buildHero(BuildContext context, Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['landing.hero.title']!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text(t['landing.hero.subtitle']!, style: const TextStyle(fontSize: 15, color: Colors.white70)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => RouterAdapter.of(context).go(context, '/$locale/hotels'),
            icon: const Icon(Icons.search),
            label: Text(t['landing.cta']!),
          ),
        ],
      ),
    ).easySeoSection(
      children: [
        SEOH1(t['landing.hero.title']!),
        SEOParagraph(t['landing.hero.subtitle']!),
      ],
    );
  }

  Widget _buildFeatures(Map<String, String> t) {
    final featureIcons = [Icons.euro, Icons.list, Icons.support];
    final featureTexts = [
      t['landing.features.bestPrice']!,
      t['landing.features.selection']!,
      t['landing.features.support']!,
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t['landing.features.title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          for (var i = 0; i < featureTexts.length; i++)
            ListTile(
              leading: Icon(featureIcons[i], color: Colors.blue),
              title: Text(featureTexts[i]),
            ),
        ],
      ),
    ).easySeoSection(
      children: [
        SEOH2(t['landing.features.title']!),
        ...featureTexts.map((f) => SEOArticle(children: [SEOParagraph(f)])),
      ],
    );
  }

  Widget _buildFaq(Map<String, String> t) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FaqBlock(
        locale: locale,
        items: [
          FaqItem(question: t['faq.q1']!, answer: t['faq.a1']!),
          FaqItem(question: t['faq.q2']!, answer: t['faq.a2']!),
          FaqItem(question: t['faq.q3']!, answer: t['faq.a3']!),
        ],
      ),
    );
  }
}
