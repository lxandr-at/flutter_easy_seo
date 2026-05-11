part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEO extends StatefulWidget {
  final Widget child;
  final bool disabled;
  final String title;
  final String? description;
  final List<EasySEOHeadTag> headTags;
  final SEOServiceInfo? serviceInfo;
  final Function({
    required String fullHtml,
    required String currentLanguage,
    required String path,
    required String headContent,
    required String bodyContent,
  })? onGenerate;
  final List<String> includeGlobals;
  final Future? whenDone;
  final ChangeNotifier? generateOnChanged;

  const EasySEO({
    Key? key,
    required this.child,
    required this.title,
    this.description,
    this.disabled = false,
    this.headTags = const [],
    this.serviceInfo,
    this.onGenerate,
    this.includeGlobals = const [],
    this.whenDone,
    this.generateOnChanged,
  }) : super(key: key);

  @override
  State<EasySEO> createState() => _EasySEOState();
}

class _EasySEOState extends State<EasySEO> {
  final _processor = SEOWidgetTreeProcessor();
  late final EasySEOFileOutput _fileHandler;
  late final EasySEOLiveOutput _liveHandler;
  late final url_helper.URLHelper _urlHelper;

  @override
  void initState() {
    super.initState();
    _fileHandler = EasySEOFileOutput();
    _liveHandler = EasySEOLiveOutput();
    _urlHelper = url_helper.URLHelper();

    if (widget.generateOnChanged != null) {
      debugPrint("EasySEO: calling gen in generateOnChanged()");
      widget.generateOnChanged!.addListener(() => _generate());
    }

    _generate();
  }

  void _generate() {
    if (widget.whenDone != null) {
      widget.whenDone!.then((_) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          debugPrint("EasySEO: calling gen in initState() after whenDone");
          _generateHTML();
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint("EasySEO: calling gen in initState()");
        _generateHTML();
      });
    }
  }

  @override
  void didUpdateWidget(EasySEO oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.title != oldWidget.title) {
      debugPrint("EasySEO: calling gen in didUpdateWidget()");
      _generate();
    }
  }

  /// Combines the explicit title adn description param with the headTags list
  List<EasySEOHeadTag> get _allTags {
    // Using a Map ensures that only one tag per "key" exists.
    final Map<String, EasySEOHeadTag> deduplicated = {};

    void addTag(EasySEOHeadTag tag) {
      deduplicated[tag.key] = tag;
    }

    // --- 1. DEFAULT AUTOMATIC TAGS ---
    String currentTitle = widget.title;
    addTag(EasySEOTitleTag(currentTitle));
    addTag(EasySEOMetaTag.title(currentTitle));
    addTag(EasySEOOgTag.title(currentTitle));
    addTag(EasySEOTwitterTag.title(currentTitle));

    // --- AUTOMATIC URL TAGS ---
    final fullUrl = _urlHelper.getCurrentUrl();
    if (fullUrl != null) {
      addTag(EasySEOLinkTag.canonical(fullUrl));
      addTag(EasySEOOgTag.url(fullUrl));
    }

    // --- AUTOMATIC LANGUAGE ALTERNATES ---
    final alternates = _urlHelper.getAlternateUrls();
    if (alternates.isNotEmpty) {
      final languages = EasySEOConfig.instance.supportedLanguages;
      final defaultLang = languages.first;

      alternates.forEach((lang, url) {
        addTag(EasySEOLinkTag.alternate(href: url, lang: lang));
      });

      // x-default using the first supported language
      if (alternates.containsKey(defaultLang)) {
        addTag(EasySEOLinkTag.alternate(href: alternates[defaultLang]!, lang: 'x-default'));
      }
    }

    if (widget.description != null) {
      addTag(EasySEOMetaTag.description(widget.description!));
      addTag(EasySEOOgTag.description(widget.description!));
      addTag(EasySEOTwitterTag.description(widget.description!));
    }

    final serviceInfo = widget.serviceInfo ?? EasySEOConfig.instance.serviceInfo;
    if (serviceInfo != null) {
      SEOServiceInfo finalInfo = serviceInfo;
      if (finalInfo.providerUrl == null) {
        finalInfo = finalInfo.copyWith(providerUrl: fullUrl);
      }
      addTag(EasySEOScriptTag(SEOHtmlJsonLd.service(finalInfo)));
    }

    // --- 2. GLOBAL OVERRIDES (from EasySEOConfig) ---
    for (var tag in EasySEOConfig.instance.headTags) {
      addTag(tag);
    }

    // --- 3. LOCAL USER OVERRIDES ---
    // Because we add these last, if the user provided their own
    // EasySEOOgTag.title, it will overwrite the automatic one above.
    for (var tag in widget.headTags) {
      addTag(tag);
    }

    return deduplicated.values.toList();
  }

  void _generateHTML() {
    // do noting if globally disabled
    if (!EasySEOConfig.instance.enabled.value) return;
    // do nothing if locally disabled
    if (widget.disabled) return;

    final rootElement = _findRootElement();
    if (rootElement == null) {
      return;
    }

    final bodyContent = _processor.processWidgetTree(rootElement, widget.includeGlobals);

    // Use page metadata from EasySEO widget
    final metadata = SEOPageMetadata(headTags: _allTags);

    final metadataStr = metadata.generateMetadata();

    if (EasySEOConfig.instance.enableLiveOutput.value) {
      _liveHandler.injectToHead(metadataStr);
      _liveHandler.injectToBody(bodyContent);
    }

    if (EasySEOConfig.instance.enableFileOutput.value || widget.onGenerate != null) {
      // Detect language from path for the <html> tag
      final currentPath = _urlHelper.getCurrentPath();
      final segments = currentPath.split('/');
      final supportedLanguages = EasySEOConfig.instance.supportedLanguages;
      String currentLang = 'en'; // Default
      
      if (segments.length > 1 && supportedLanguages.contains(segments[1])) {
        currentLang = segments[1];
      } else if (supportedLanguages.isNotEmpty) {
        currentLang = supportedLanguages.first;
      }

      final fullHtml = SEOHtmlDocumentGenerator.generateFullDocument(
        bodyContent: bodyContent,
        metadata: metadataStr,
        lang: currentLang,
      );
      if (EasySEOConfig.instance.enableFileOutput.value) {
        _fileHandler.saveHTMLFile(fullHtml);
      }
      // Call the callback if provided
      if (!EasySEOConfig.instance.disableOnGenerate.value) {
        widget.onGenerate?.call(
          fullHtml: fullHtml,
          currentLanguage: currentLang,
          path: currentPath,
          headContent: metadataStr,
          bodyContent: bodyContent,
        );
      }
    }
  }

  Element? _findRootElement() {
    final element = context as Element;
    return element;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
