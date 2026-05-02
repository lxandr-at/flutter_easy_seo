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

  testWidgets('SEOWidgetTreeProcessor reorders heading siblings by priority', (WidgetTester tester) async {
    // Widget tree has h2 before h1 — h1 must appear first in HTML output.
    await tester.pumpWidget(
      const MaterialApp(
        home: EasySEO(
          title: 'Priority Test',
          child: Scaffold(
            body: Column(
              children: [
                SEOTextWrapper(textType: SEOTextType.h2, child: Text('Subtitle')),
                SEOTextWrapper(textType: SEOTextType.p, child: Text('Body text')),
                SEOTextWrapper(textType: SEOTextType.h1, child: Text('Main Title')),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final element = tester.element(find.byType(EasySEO));
    final processor = SEOWidgetTreeProcessor();
    final html = processor.processWidgetTree(element, []);

    final h1Index = html.indexOf('<h1>Main Title</h1>');
    final h2Index = html.indexOf('<h2>Subtitle</h2>');
    final pIndex = html.indexOf('<p>Body text</p>');

    expect(h1Index, greaterThanOrEqualTo(0), reason: 'h1 must be present');
    expect(h2Index, greaterThanOrEqualTo(0), reason: 'h2 must be present');
    expect(pIndex, greaterThanOrEqualTo(0), reason: 'p must be present');

    expect(h1Index, lessThan(h2Index), reason: 'h1 must appear before h2');
    expect(h2Index, lessThan(pIndex), reason: 'h2 must appear before p');
  });

  testWidgets('SEOWidgetTreeProcessor bubbles up heading priority through containers', (WidgetTester tester) async {
    // h1 is deep inside a container that comes after a section.
    // The container holding h1 should be moved before the section.
    await tester.pumpWidget(
      const MaterialApp(
        home: EasySEO(
          title: 'Bubbling Test',
          child: Scaffold(
            body: Column(
              children: [
                SEOSectionWrapper(child: Text('Section content')),
                // This Padding (or any non-wrapper widget) will be a container node.
                Padding(
                  padding: EdgeInsets.all(8),
                  child: SEOTextWrapper(textType: SEOTextType.h1, child: Text('Deep Title')),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final element = tester.element(find.byType(EasySEO));
    final processor = SEOWidgetTreeProcessor();
    final html = processor.processWidgetTree(element, []);

    final h1Index = html.indexOf('<h1>Deep Title</h1>');
    final sectionIndex = html.indexOf('<section>');

    expect(h1Index, greaterThanOrEqualTo(0));
    expect(sectionIndex, greaterThanOrEqualTo(0));

    // Currently, this will likely FAIL because Padding doesn't have a tagName, 
    // so it's not prioritized over SEOSectionWrapper.
    expect(h1Index, lessThan(sectionIndex), reason: 'Deep h1 should move its parent container before the section');
  });
}
