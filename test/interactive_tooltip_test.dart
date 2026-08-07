import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  tearDown(() {
    EasySEOManager.instance.showHighlights.value = false;
    EasySEOManager.instance.clear();
  });

  testWidgets('interactive hover tooltip shows the stable literal wrapper name', (tester) async {
    EasySEOManager.instance.showHighlights.value = true;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EasySEOSectionWrapper(
            child: Text('content'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, 'EasySEOSectionWrapper');
  });
}
