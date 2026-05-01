part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOContainerWrapper extends BaseSEOWrapper {
  const SEOContainerWrapper({
    super.key,
    required Widget child,
    String tag = 'div',
    String? className,
    Map<String, String>? attributes,
  }) : _tag = tag, super(child: child, className: className, attributes: attributes);

  final String _tag;

  @override
  String get tagName => _tag;

  @override
  State<StatefulWidget> createState() => _SEOContainerWrapperState();
}

class _SEOContainerWrapperState extends BaseSEOWrapperState<SEOContainerWrapper> {}