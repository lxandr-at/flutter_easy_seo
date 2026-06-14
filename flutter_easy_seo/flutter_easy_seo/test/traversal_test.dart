import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  testWidgets('SEOWidgetTreeProcessor generates correct HTML for nested widgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EasySEOPage(
          title: 'Test Page',
          child: Scaffold(
            body: Column(
              children: [
                EasySEOTextWrapper(
                  textType: SEOTextType.h1,
                  child: Text('Main Title'),
                ),
                EasySEOTextWrapper(
                  textType: SEOTextType.p,
                  child: Text('Some description'),
                ),
                EasySEONavLinkWrapper(
                  path: '/details',
                  child: EasySEOTextWrapper(
                    textType: SEOTextType.p,
                    child: Text('View Details'),
                  ),
                ),
                EasySEOImageWrapper(
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

    final element = tester.element(find.byType(EasySEOPage));
    final processor = SEOWidgetTreeProcessor();
    final html = processor.processWidgetTree(element, []);

    expect(html, contains('<h1>Main Title</h1>'));
    expect(html, contains('<p>Some description</p>'));
    expect(html, contains('<li>'));
    expect(html, contains('<a href="/details">'));
    expect(html, contains('<p>View Details</p>'));
    expect(html, contains('<img src="https://example.com/image.png" alt="Test Image" />'));
  });

  testWidgets('SEOWidgetTreeProcessor reorders heading siblings by priority', (WidgetTester tester) async {
    // Widget tree has h2 before h1 — h1 must appear first in HTML output.
    await tester.pumpWidget(
      const MaterialApp(
        home: EasySEOPage(
          title: 'Priority Test',
          child: Scaffold(
            body: Column(
              children: [
                EasySEOTextWrapper(textType: SEOTextType.h2, child: Text('Subtitle')),
                EasySEOTextWrapper(textType: SEOTextType.p, child: Text('Body text')),
                EasySEOTextWrapper(textType: SEOTextType.h1, child: Text('Main Title')),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final element = tester.element(find.byType(EasySEOPage));
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
        home: EasySEOPage(
          title: 'Bubbling Test',
          child: Scaffold(
            body: Column(
              children: [
                EasySEOSectionWrapper(child: Text('Section content')),
                // This Padding (or any non-wrapper widget) will be a container node.
                Padding(
                  padding: EdgeInsets.all(8),
                  child: EasySEOTextWrapper(textType: SEOTextType.h1, child: Text('Deep Title')),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final element = tester.element(find.byType(EasySEOPage));
    final processor = SEOWidgetTreeProcessor();
    final html = processor.processWidgetTree(element, []);

    final h1Index = html.indexOf('<h1>Deep Title</h1>');
    final sectionIndex = html.indexOf('<section>');

    expect(h1Index, greaterThanOrEqualTo(0));
    expect(sectionIndex, greaterThanOrEqualTo(0));

    // Currently, this will likely FAIL because Padding doesn't have a tagName,
    // so it's not prioritized over EasySEOSectionWrapper.
    expect(h1Index, lessThan(sectionIndex), reason: 'Deep h1 should move its parent container before the section');
  });

  testWidgets('SEOWidgetTreeProcessor supports additionalTags', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EasySEOPage(
          title: 'Additional Tags Test',
          child: Scaffold(
            body: Column(
              children: [
                EasySEOSectionWrapper(
                  additionalTags: [
                    SEOHtml(tag: 'h2', content: 'Section Subtitle'),
                    SEOHtml(
                      tag: 'script',
                      attributes: {'type': 'application/ld+json'},
                      content: '{"@type":"Article"}',
                    ),
                  ],
                  child: EasySEOTextWrapper(textType: SEOTextType.p, child: Text('Section content')),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final element = tester.element(find.byType(EasySEOPage));
    final processor = SEOWidgetTreeProcessor();
    final html = processor.processWidgetTree(element, []);

    // Heading tags in additionalTags should be prepended
    final h2Index = html.indexOf('<h2>Section Subtitle</h2>');
    final sectionContentIndex = html.indexOf('Section content');
    final scriptIndex = html.indexOf('<script type="application/ld+json">{"@type":"Article"}</script>');

    expect(h2Index, greaterThanOrEqualTo(0), reason: 'HTML: $html');
    expect(sectionContentIndex, greaterThanOrEqualTo(0));
    expect(scriptIndex, greaterThanOrEqualTo(0));

    expect(h2Index, lessThan(sectionContentIndex), reason: 'h2 should be prepended before content');
    expect(sectionContentIndex, lessThan(scriptIndex), reason: 'script should be appended after content');
  });
}
