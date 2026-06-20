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

  static final Map<Type, Color> _highlightColors = {
    EasySEOHeaderWrapper: const Color(0xFFFF9800),
    EasySEOContainerWrapper: const Color(0xFF009688),
    EasySEOArticleWrapper: const Color(0xFF9C27B0),
    EasySEOAsideWrapper: const Color(0xFFE91E63),
    EasySEOSectionWrapper: const Color(0xFF00BCD4),
    EasySEONavWrapper: const Color(0xFF3F51B5),
    EasySEOMainWrapper: const Color(0xFF4CAF50),
    EasySEOFooterWrapper: const Color(0xFF795548),
    EasySEOListWrapper: const Color(0xFFFF5722),
    EasySEOListItemWrapper: const Color(0xFFCDDC39),
    EasySEOImageWrapper: const Color(0xFFF44336),
    EasySEOTextWrapper: const Color(0xFF607D8B),
    EasySEOTimeWrapper: const Color(0xFFFFC107),
    EasySEOFigureWrapper: const Color(0xFF673AB7),
    EasySEOFormWrapper: const Color(0xFF03A9F4),
    EasySEOLinkWrapper: const Color(0xFFFFEB3B),
    EasySeoNavAnchorWrapper: const Color(0xFFFFEB3B),
    EasySEOFaqWrapper: const Color(0xFF8BC34A),
  };

  Color get highlightColor => _highlightColors[runtimeType] ?? const Color(0xFF9E9E9E);
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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: EasySEOManager.instance.showHighlights,
      builder: (context, show, child) {
        if (!show) return child!;
        return Tooltip(
          message: widget.runtimeType.toString(),
          waitDuration: const Duration(seconds: 1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: widget.highlightColor, width: 3.5),
              borderRadius: BorderRadius.circular(6),
            ),
            position: DecorationPosition.foreground,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
