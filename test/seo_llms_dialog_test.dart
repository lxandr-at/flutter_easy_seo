import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  setUp(() => EasySEOManager.instance.clear());

  testWidgets('Generate LLMs dialog switches between llms.txt and llms-full.txt via chips', (tester) async {
    final manager = EasySEOManager.instance;
    manager.init(
      baseUrl: 'https://preisvergleich.lxandr.at',
      supportedLanguages: ['de'],
      pages: ['/'],
      enableInteractiveMode: true,
    );
    manager.showResultDialog.value = true;

    await tester.pumpWidget(
      MaterialApp(
        home: EasySEOPage(
          title: 'Interactive Test',
          child: Scaffold(
            body: Center(
              child: EasySEOTextWrapper(
                textType: SEOTextType.h1,
                text: 'Content',
                child: Text('Content'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate LLMs'));
    await tester.pumpAndSettle();

    // Both files are offered as selectable chips.
    expect(find.text('Generated LLMs Files'), findsOneWidget);
    expect(find.text('llms.txt'), findsOneWidget);
    expect(find.text('llms-full.txt'), findsOneWidget);

    String displayed() =>
        tester.widget<SelectableText>(find.byType(SelectableText)).data ?? '';

    // Default selection shows llms.txt (no llms-full metadata).
    expect(displayed(), contains('## Routes /de'));
    expect(displayed(), isNot(contains('**URL:**')));

    // Switching to llms-full.txt shows the full-format entry.
    await tester.tap(find.text('llms-full.txt'));
    await tester.pumpAndSettle();

    expect(displayed(), contains('**URL:**'));
    expect(displayed(), contains('# Content'));
  });
}
