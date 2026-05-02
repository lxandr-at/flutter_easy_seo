part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEONavWrapper extends BaseSEOWrapper {
  final String? label;

  const SEONavWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    super.globalName,
    this.label,
  });

  @override
  String get tagName => "nav";

  @override
  String get appendBeforeContent => "<ul>";

  @override
  String get appendAfterContent => "</ul>";

  @override
  State<StatefulWidget> createState() => _SEONavWrapperState();
}

class _SEONavWrapperState extends BaseSEOWrapperState<SEONavWrapper> {}
