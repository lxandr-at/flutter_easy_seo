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
    List<SEOHtml> additionalTags = const [],
  }) : _additionalTags = additionalTags;

  final Widget child;
  final String? className;
  final Map<String, String?>? attributes;
  final String? globalName;
  final Map<String, dynamic>? jsonLd;
  final List<SEOHtml> _additionalTags;
  List<SEOHtml> get additionalTags => _additionalTags;

  Map<String, String> get additionalAttributes => {};

  static const _headingPriority = {
    'h1': 0, 'h2': 1, 'h3': 2, 'h4': 3, 'h5': 4, 'h6': 5,
  };

  @protected
  SEOHtml _buildSimpleTag({
    required String tag,
    required List<SEOHtml> children,
    required BuildContext context,
    String? content,
  }) {
    final resolvedAdditional = additionalTags.map((t) => t.resolve(context)).toList();
    final headTags = resolvedAdditional.where((t) => _headingPriority.containsKey(t.tag)).toList();
    headTags.sort((a, b) => (_headingPriority[a.tag] ?? 6).compareTo(_headingPriority[b.tag] ?? 6));
    final otherTags = resolvedAdditional.where((t) => !_headingPriority.containsKey(t.tag)).toList();

    return SEOHtml(
      tag: tag,
      content: content,
      attributes: _buildAttributes(),
      jsonLd: jsonLd,
      children: [
        ...headTags,
        ...children,
        ...otherTags,
      ],
    );
  }

  Map<String, String>? _buildAttributes() {
    final attrs = <String, String>{};
    if (className != null) attrs['class'] = className!;
    attrs.addAll(additionalAttributes);
    if (attributes != null) {
      for (final e in attributes!.entries) {
        if (e.value != null && e.value!.isNotEmpty) {
          attrs[e.key] = e.value!;
        } else {
          attrs[e.key] = '';
        }
      }
    }
    return attrs.isNotEmpty ? attrs : null;
  }
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
