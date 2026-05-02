part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOHeaderWrapper extends BaseSEOWrapper {
  const SEOHeaderWrapper({
    super.key,
    required Widget child,
    String? className,
    Map<String, String>? attributes,
  }) : super(child: child, className: className, attributes: attributes);

  @override
  String get tagName => 'header';

  @override
  State<StatefulWidget> createState() => _SEOHeaderWrapperState();
}

class _SEOHeaderWrapperState extends BaseSEOWrapperState<SEOHeaderWrapper> {}
