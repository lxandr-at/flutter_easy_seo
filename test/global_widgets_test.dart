import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  setUp(() {
    EasySEOManager.instance.clear();
  });

  testWidgets('named wrapper registers a global on mount and unregisters on dispose', (tester) async {
    final globals = EasySEOManager.instance.globals;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EasySEOSectionWrapper(
            globalName: 'test-global',
            child: Text('content'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(EasySEOSectionWrapper));
    expect(globals['test-global'], same(element));

    // Unmounting the wrapper must remove the registration.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('empty'))));
    await tester.pumpAndSettle();

    expect(globals.containsKey('test-global'), isFalse);
  });

  testWidgets('dispose of an older instance does not clobber a newer registration', (tester) async {
    final globals = EasySEOManager.instance.globals;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              EasySEOSectionWrapper(
                key: ValueKey('first'),
                globalName: 'shared',
                child: Text('first'),
              ),
              EasySEOSectionWrapper(
                key: ValueKey('second'),
                globalName: 'shared',
                child: Text('second'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Last built instance wins.
    final firstElement = tester.element(find.byKey(const ValueKey('first')));
    final secondElement = tester.element(find.byKey(const ValueKey('second')));
    expect(globals['shared'], same(secondElement));
    expect(firstElement, isNot(same(secondElement)));

    // Disposing the FIRST instance must not remove the second's registration.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              EasySEOSectionWrapper(
                key: ValueKey('second'),
                globalName: 'shared',
                child: Text('second'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(globals['shared'], same(secondElement));

    // Disposing the last instance unregisters it.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('empty'))));
    await tester.pumpAndSettle();

    expect(globals.containsKey('shared'), isFalse);
  });

  testWidgets('dropping the globalName removes the stale registration', (tester) async {
    final globals = EasySEOManager.instance.globals;

    Widget build(String? name) => MaterialApp(
          home: Scaffold(
            body: EasySEOSectionWrapper(
              globalName: name,
              child: const Text('content'),
            ),
          ),
        );

    await tester.pumpWidget(build('named'));
    await tester.pumpAndSettle();
    expect(globals.containsKey('named'), isTrue);

    await tester.pumpWidget(build(null));
    await tester.pumpAndSettle();
    expect(globals.containsKey('named'), isFalse);
  });

  testWidgets('clear() empties the global registry', (tester) async {
    final globals = EasySEOManager.instance.globals;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EasySEOSectionWrapper(
            globalName: 'test-global',
            child: Text('content'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(globals.containsKey('test-global'), isTrue);

    EasySEOManager.instance.clear();
    expect(globals, isEmpty);
  });
}
