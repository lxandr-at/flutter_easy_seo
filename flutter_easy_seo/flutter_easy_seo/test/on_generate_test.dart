import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  testWidgets('EasySEO.onGenerate provides all metadata parameters', (WidgetTester tester) async {
    String? capturedFullHtml;
    String? capturedLang;
    String? capturedPath;
    String? capturedHead;
    String? capturedBody;

    EasySEOConfig.instance.onGenerate = (EasySEOGenerationResult gen) {
      capturedFullHtml = gen.fullHtml;
      capturedLang = gen.currentLanguage;
      capturedPath = gen.path;
      capturedHead = gen.headContent;
      capturedBody = gen.bodyContent;
    };

    await tester.pumpWidget(
      MaterialApp(
        home: EasySEO(
          title: 'Test Page',
          description: 'Test Description',
          child: const Scaffold(
            body: SEOTextWrapper(
              textType: SEOTextType.h1,
              child: Text('Hello SEO'),
            ),
          ),
        ),
      ),
    );

    // Give some time for post frame callback and possible microtasks
    await tester.pumpAndSettle();

    expect(capturedFullHtml, isNotNull);
    expect(capturedLang, isNotNull);
    expect(capturedPath, isNotNull);
    expect(capturedHead, isNotNull);
    expect(capturedBody, isNotNull);

    expect(capturedFullHtml, contains('<title data-easy-seo="title">Test Page</title>'));
    expect(capturedFullHtml, contains('<h1>Hello SEO</h1>'));
    
    expect(capturedHead, contains('<title data-easy-seo="title">Test Page</title>'));
    expect(capturedHead, contains('name="description" content="Test Description"'));
    
    expect(capturedBody, contains('<h1>Hello SEO</h1>'));
    
    // Default lang in test environment might be 'en' or similar depending on setup, 
    // but it should be captured.
    expect(capturedLang, isNotEmpty);
  });
}
