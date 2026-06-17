import 'package:flutter/material.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SaaS Platform').easySeoH1,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (index) {
              if (index == 0) {
                context.go('/');
              } else {
                context.go('/services');
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: const Text('Home').easySeoNavAnchor(path: "/", text: 'Home'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.business_outlined),
                selectedIcon: const Icon(Icons.business),
                label: const Text('Services').easySeoNavAnchor(path: "/services", text: 'Services'),
              ),
            ],
          ).easySeo(globalName: 'Main Navigation'),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade600,
                          Colors.blue.shade800,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome to Our Platform').easySeoH2,
                        const SizedBox(height: 16),
                        const Text(
                          'Transform your business with our cutting-edge solutions. '
                          'We provide enterprise-grade tools for modern teams.',
                        ).easySeoP,
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go('/services'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Explore Services'),
                        ),
                      ],
                    ),
                  ).easySeo(tag: 'section'),

                  const SizedBox(height: 32),

                  // Hero Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://picsum.photos/seed/home/800/400',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ).easySeo(alt: 'SaaS Platform Dashboard Overview'),
                  ),

                  const SizedBox(height: 32),

                  // Features Section
                  const Text('Our Features').easySeo(textType: SEOTextType.h2),
                  const SizedBox(height: 16),

                  // Feature Cards Grid
                  const Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _FeatureCard(
                        icon: Icons.speed,
                        title: 'Lightning Fast',
                        description:
                            'Optimized performance for enterprise workloads.',
                      ),
                      _FeatureCard(
                        icon: Icons.security,
                        title: 'Secure by Default',
                        description: 'Bank-level encryption and compliance.',
                      ),
                      _FeatureCard(
                        icon: Icons.cloud,
                        title: 'Cloud Native',
                        description:
                            'Deploy anywhere with our flexible infrastructure.',
                      ),
                      _FeatureCard(
                        icon: Icons.support_agent,
                        title: '24/7 Support',
                        description: 'Expert help whenever you need it.',
                      ),
                      EasySEOConfigWidget()
                    ],
                  ),

                  const SizedBox(height: 32),

                  // CTA Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('Ready to get started?')
                            .easySeo(textType: SEOTextType.h3),
                        const SizedBox(height: 12),
                        const Text(
                          'Join thousands of companies using our platform.',
                        ).easySeo(textType: SEOTextType.p),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/services'),
                          child: const Text('View Services'),
                        ),
                      ],
                    ),
                  ).easySeo(tag: 'section'),

                  const SizedBox(height: 32),

                  // Footer with Custom Navigation Links
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quick Links').easySeo(textType: SEOTextType.h4),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            const Text('Home').easySeoNavAnchor(path: '/', text: 'Home'),
                            const Text('Services').easySeoNavAnchor(path: '/services', text: 'Services'),
                            const Text('Contact').easySeoNavAnchor(path: '/contact', text: 'Contact'),
                            const Text('About').easySeoNavAnchor(path: '/about', text: 'About'),
                          ],
                        ).easySeoNav(globalName: 'Footer Navigation'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.blue.shade600),
          const SizedBox(height: 12),
          Text(title).easySeo(textType: SEOTextType.h3),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    );
  }
}
