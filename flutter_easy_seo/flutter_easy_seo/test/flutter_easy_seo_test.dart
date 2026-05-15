import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  test('EasySEO can be instantiated', () {
    expect(
      const EasySEOPage(
        disabled: true,
        title: '',
        child: SizedBox(),
      ),
      isNotNull,
    );
  });
}
