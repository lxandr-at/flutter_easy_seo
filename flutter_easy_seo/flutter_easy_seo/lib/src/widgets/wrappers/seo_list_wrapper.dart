part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOListWrapper extends BaseSEOWrapper {
  const SEOListWrapper({
    super.key,
    required Widget child,
    String? className,
    Map<String, String>? attributes,
  }) : super(child: child, className: className, attributes: attributes);

  @override
  String get tagName => "ul";

  @override
  State<StatefulWidget> createState() => _SEOListWrapperState();
}

class _SEOListWrapperState extends BaseSEOWrapperState<SEOListWrapper> {}
