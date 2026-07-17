part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

/// Interface for wrapper widgets that can produce an [SEOHtml] node for the
/// generated HTML output.
abstract class EasySEOWrapper {
  /// Builds the [SEOHtml] representation of this wrapper, including its
  /// [children], [navItems], and the current [BuildContext].
  SEOHtml toSEOHtml({
    required List<SEOHtml> children,
    required List<SEONavItem> navItems,
    required BuildContext context,
  });
}

/// Base class for all SEO wrapper widgets that decorate a [child] widget tree
/// with semantic HTML tags, attributes, JSON-LD, and optional global registration.
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

  /// The widget tree being wrapped.
  final Widget child;

  /// Optional CSS class name applied to the generated HTML element.
  final String? className;

  /// Additional HTML attributes for the generated element.
  final Map<String, String?>? attributes;

  /// Global identifier for cross-page inclusion. Widgets with the same
  /// [globalName] are registered with [EasySEOManager] so they can be
  /// pulled into generated pages outside this page's widget tree.
  final String? globalName;

  /// Optional JSON-LD structured data object.
  final Map<String, dynamic>? jsonLd;

  final List<SEOHtml> _children;

  /// Pre-defined [SEOHtml] child nodes nested inside this wrapper.
  List<SEOHtml> get children => _children;

  /// Override point for subclasses to supply extra HTML attributes that are
  /// always present on the generated element.
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

  /// Color used for the debug highlight border when [EasySEOManager.showHighlights]
  /// is enabled, determined by the concrete wrapper type.
  Color get highlightColor => _highlightColors[runtimeType] ?? const Color(0xFF9E9E9E);
}

/// Base state for [EasySEOBaseWrapper] subclasses. Handles registration of
/// [EasySEOBaseWrapper.globalName] and renders the debug highlight border.
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
