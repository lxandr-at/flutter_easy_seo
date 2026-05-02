part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEONavLinkWrapper extends BaseSEOWrapper {
  final String path;
  final String? text;

  const SEONavLinkWrapper({
    super.key,
    required super.child,
    super.className,
    super.attributes,
    required this.path,
    this.text,
  });

  @override
  String get tagName => "a";

  @override
  String getContent() => text ?? "";

  @override
  String get appendBeforeTag => "<li>";

  @override
  String get appendAfterTag => "</li>";

  @override
  Map<String, String> get additionalAttributes => {'href': path};

  @override
  State<StatefulWidget> createState() => _SEONavLinkWrapperState();
}

class _SEONavLinkWrapperState extends BaseSEOWrapperState<SEONavLinkWrapper> {}
