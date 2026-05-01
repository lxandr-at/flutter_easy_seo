part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOListWrapper extends BaseSEOWrapper {
  const SEOListWrapper({
    super.key,
    required Widget child,
    required String tag,
    String? className,
    Map<String, String>? attributes,
  }) : _tag = tag, super(child: child, className: className, attributes: attributes);

  final String _tag;

  @override
  String get tagName => _tag;

  @override
  State<StatefulWidget> createState() => _SEOListWrapperState();
}

class _SEOListWrapperState extends BaseSEOWrapperState<SEOListWrapper> {}