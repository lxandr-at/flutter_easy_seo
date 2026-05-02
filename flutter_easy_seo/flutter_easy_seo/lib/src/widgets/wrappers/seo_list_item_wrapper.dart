part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOListItemWrapper extends BaseSEOWrapper {
  const SEOListItemWrapper({
    super.key,
    required Widget child,
    String? className,
    Map<String, String>? attributes,
  }) : super(child: child, className: className, attributes: attributes);

  @override
  String get tagName => "li";

  @override
  State<StatefulWidget> createState() => _SEOListItemWrapperState();
}

class _SEOListItemWrapperState extends BaseSEOWrapperState<SEOListItemWrapper> {}
