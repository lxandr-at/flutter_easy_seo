part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEO extends StatefulWidget {
  final Widget child;
  final bool disabled;
  final String title;
  final String? description;
  final List<EasySEOHeadTag> headTags;
  final Function(String html)? onGenerate;

  const EasySEO({
    Key? key,
    required this.child,
    required this.title,
    this.description,
    this.disabled = false,
    this.headTags = const [],
    this.onGenerate,
  }) : super(key: key);

  @override
  State<EasySEO> createState() => _EasySEOState();
}

class _EasySEOState extends State<EasySEO> {
  final _processor = SEOWidgetTreeProcessor();
  late final EasySEOFileOutput _fileHandler;
  late final EasySEOLiveOutput _liveHandler;

  @override
  void initState() {
    super.initState();
    _fileHandler = EasySEOFileOutput();
    _liveHandler = EasySEOLiveOutput();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateHTML();
    });
  }

  /// Combines the explicit title adn description param with the headTags list
  List<EasySEOHeadTag> get _allTags {
    // Using a Map ensures that only one tag per "key" exists.
    final Map<String, EasySEOHeadTag> deduplicated = {};

    void addTag(EasySEOHeadTag tag) {
      deduplicated[tag.key] = tag;
    }

    // --- 1. DEFAULT AUTOMATIC TAGS ---
    addTag(EasySEOTitleTag(widget.title));
    addTag(EasySEOMetaTag.title(widget.title));
    addTag(EasySEOOgTag.title(widget.title));
    addTag(EasySEOTwitterTag.title(widget.title));

    if (widget.description != null) {
      addTag(EasySEOMetaTag.description(widget.description!));
      addTag(EasySEOOgTag.description(widget.description!));
      addTag(EasySEOTwitterTag.description(widget.description!));
    }

    // --- 2. USER OVERRIDES ---
    // Because we add these last, if the user provided their own
    // EasySEOOgTag.title, it will overwrite the automatic one above.
    for (var tag in widget.headTags) {
      addTag(tag);
    }

    return deduplicated.values.toList();
  }

  void _generateHTML() {
    // do noting if globally disabled
    if (!EasySEOConfig.enabled.value) return;
    // do nothing if locally disabled
    if (widget.disabled) return;
    
    final rootElement = _findRootElement();
    if (rootElement == null) {
      return;
    }

    final bodyContent = _processor.processWidgetTree(rootElement);
    
    // Use page metadata from EasySEO widget
    final metadata = SEOPageMetadata(headTags: _allTags);

    final metadataStr = metadata.generateMetadata();

    if (EasySEOConfig.enableLiveOutput.value) {
      _liveHandler.injectToHead(metadataStr);
      _liveHandler.injectToBody(bodyContent);
    }

    if (EasySEOConfig.enableFileOutput.value || widget.onGenerate != null) {
      final fullHtml = SEOHtmlDocumentGenerator.generateFullDocument(
        bodyContent: bodyContent,
        metadata: metadataStr,
      );
      if (EasySEOConfig.enableFileOutput.value) {
        _fileHandler.saveHTMLFile(fullHtml);
      }
      // Call the callback if provided
      widget.onGenerate?.call(fullHtml);
    }

  }

  Element? _findRootElement() {
    final element = context as Element;
    return element;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}