part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEO extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final String? title;
  final String? description;
  final Map<String, String>? additionalTags;
  final Function(String html, String route)? onGenerate;

  const EasySEO({
    Key? key,
    required this.child,
    this.enabled = false,
    this.title,
    this.description,
    this.additionalTags,
    this.onGenerate,
  }) : super(key: key);

  @override
  State<EasySEO> createState() => _EasySEOState();
}

class _EasySEOState extends State<EasySEO> {
  final _processor = SEOWidgetTreeProcessor();
  late final FileSystemHandler _fileHandler;

  @override
  void initState() {
    super.initState();
    _fileHandler = FileSystemHandler();
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateHTML();
      });
    }
  }

  void _generateHTML() {
    if (!widget.enabled) return;
    
    final route = getCurrentWebRoute();

    final rootElement = _findRootElement();
    if (rootElement == null) {
      return;
    }

    final bodyContent = _processor.processWidgetTree(rootElement);
    
    // Use page metadata from EasySEO widget
    final metadata = SEOPageMetadata(
      title: widget.title,
      description: widget.description,
      additionalTags: widget.additionalTags,
    );

    final html = SEOHtmlDocumentGenerator.generateFullDocument(
      bodyContent: bodyContent,
      metadata: metadata,
    );

    _fileHandler.saveHTMLFile(html);

    if (widget.onGenerate != null) {
      widget.onGenerate!(html, route);
    }
  }

  Element? _findRootElement() {
    final element = context as Element;
    return element;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}