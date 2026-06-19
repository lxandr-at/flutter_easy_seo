part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

abstract class EasySEOWrapper {
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  });
}

abstract class EasySEOBaseWrapper extends StatefulWidget implements EasySEOWrapper {
  const EasySEOBaseWrapper({
    super.key,
    required this.child,
    this.className,
    this.attributes,
    this.globalName,
    this.jsonLd,
    List<SEOHtml> children = const [],
  }) : _children = children;

  final Widget child;
  final String? className;
  final Map<String, String?>? attributes;
  final String? globalName;
  final Map<String, dynamic>? jsonLd;
  final List<SEOHtml> _children;
  List<SEOHtml> get children => _children;

  Map<String, String> get additionalAttributes => {};
}

abstract class EasySEOBaseWrapperState<T extends EasySEOBaseWrapper> extends State<T> {
  @override
  void initState() {
    super.initState();
    if (widget.globalName != null) {
      EasySEOManager.instance.globals[widget.globalName!] = context;
    }
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.globalName != null) {
      EasySEOManager.instance.globals[widget.globalName!] = context;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
