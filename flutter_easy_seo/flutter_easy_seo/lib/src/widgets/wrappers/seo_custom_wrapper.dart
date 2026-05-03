part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class SEOCustomWrapper extends BaseSEOWrapper {
  final Widget Function(BuildContext, Widget)? builder;
  final String? tag;

  const SEOCustomWrapper({
    super.key,
    required super.child,
    this.builder,
    this.tag,
    super.className,
    super.attributes,
    super.additionalTags,
  });

  @override
  String get tagName => tag ?? 'div';

  @override
  State<StatefulWidget> createState() => _SEOCustomWrapperState();
}

class _SEOCustomWrapperState extends BaseSEOWrapperState<SEOCustomWrapper> {}
