import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:go_router/go_router.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: 1,
            onDestinationSelected: (index) {
              if (index == 0) {
                context.go('/');
              } else {
                context.go('/services');
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: Text('Services'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.shade600,
                          Colors.indigo.shade800,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Our Services',
                        ).easySeo(textType: SEOTextType.h1),
                        const SizedBox(height: 12),
                        const Text(
                          'Discover our comprehensive suite of services designed to help your business grow.',
                        ).easySeo(textType: SEOTextType.p),
                      ],
                    ),
                  ).easySeo(tag: 'section'),

                  const SizedBox(height: 32),

                  // Service Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://picsum.photos/seed/services/800/400',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ).easySeo(alt: 'Professional Services Team Collaboration'),
                  ),

                  const SizedBox(height: 32),

                  // Service Details
                  const Text('What We Offer').easySeo(textType: SEOTextType.h2),
                  const SizedBox(height: 24),

                  // Service 1
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.analytics,
                                color: Colors.blue.shade600, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                                child: const Text('Data Analytics')
                                    .easySeo(textType: SEOTextType.h3)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Transform raw data into actionable insights with our advanced analytics platform. '
                          'Real-time dashboards, custom reports, and machine learning powered predictions.',
                        ).easySeo(textType: SEOTextType.p),
                        const SizedBox(height: 12),
                        const Wrap(
                          spacing: 8,
                          children: [
                            Chip(label: Text('Real-time')),
                            Chip(label: Text('Custom Reports')),
                            Chip(label: Text('ML Predictions')),
                          ],
                        ),
                      ],
                    ),
                  ).easySeo(tag: 'article'),

                  const SizedBox(height: 16),

                  // Service 2
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cloud_sync,
                                color: Colors.green.shade600, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                                child: const Text('Cloud Infrastructure')
                                    .easySeo(textType: SEOTextType.h3)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Scalable cloud solutions that grow with your business. From startup to enterprise, '
                          'we provide the infrastructure you need to succeed.',
                        ).easySeo(textType: SEOTextType.p),
                        const SizedBox(height: 12),
                        const Wrap(
                          spacing: 8,
                          children: [
                            Chip(label: Text('Auto-scaling')),
                            Chip(label: Text('99.9% Uptime')),
                            Chip(label: Text('Global CDN')),
                          ],
                        ),
                      ],
                    ),
                  ).easySeo(tag: 'article'),

                  const SizedBox(height: 16),

                  // Service 3
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.security,
                                color: Colors.orange.shade600, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                                child: const Text('Security & Compliance')
                                    .easySeo(textType: SEOTextType.h3)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Enterprise-grade security with SOC2, GDPR, and HIPAA compliance. '
                          'Protect your data with bank-level encryption and 24/7 monitoring.',
                        ).easySeo(textType: SEOTextType.p),
                        const SizedBox(height: 12),
                        const Wrap(
                          spacing: 8,
                          children: [
                            Chip(label: Text('SOC2')),
                            Chip(label: Text('GDPR')),
                            Chip(label: Text('HIPAA')),
                          ],
                        ),
                      ],
                    ),
                  ).easySeo(tag: 'article'),

                  const SizedBox(height: 32),

                  // Contact CTA
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Need a Custom Solution?')
                            .easySeo(textType: SEOTextType.h3),
                        const SizedBox(height: 12),
                        const Text(
                          'Our team of experts can help design a solution tailored to your specific needs.',
                        ).easySeo(textType: SEOTextType.p),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Contact Us'),
                        ),
                      ],
                    ),
                  ).easySeo(tag: 'section'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
