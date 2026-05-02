import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  testWidgets('SEOWidgetTreeProcessor generates correct HTML for nested widgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EasySEO(
          title: 'Test Page',
          child: Scaffold(
            body: Column(
              children: [
                SEOTextWrapper(
                  textType: SEOTextType.h1,
                  child: Text('Main Title'),
                ),
                SEOTextWrapper(
                  textType: SEOTextType.p,
                  child: Text('Some description'),
                ),
                SEONavLinkWrapper(
                  path: '/details',
                  child: SEOTextWrapper(
                    textType: SEOTextType.p,
                    child: Text('View Details'),
                  ),
                ),
                SEOImageWrapper(
                  alt: 'Test Image',
                  src: 'https://example.com/image.png',
                  child: SizedBox(width: 100, height: 100),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Give some time for post frame callback
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(EasySEO));
    final processor = SEOWidgetTreeProcessor();
    final html = processor.processWidgetTree(element, []);

    expect(html, contains('<h1>Main Title</h1>'));
    expect(html, contains('<p>Some description</p>'));
    expect(html, contains('<li><a href="/details"><p>View Details</p></a></li>'));
    expect(html, contains('<img src="https://example.com/image.png" alt="Test Image" />'));
  });
}
