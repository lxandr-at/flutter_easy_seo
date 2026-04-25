import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  test('EasySEO can be instantiated', () {
    expect(
      const EasySEO(
        enabled: true,
        child: SizedBox(),
      ),
      isNotNull,
    );
  });
}