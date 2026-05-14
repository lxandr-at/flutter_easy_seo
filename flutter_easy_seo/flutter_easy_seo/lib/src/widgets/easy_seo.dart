part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class FutureTracker {
  bool _isDone = false;
  bool get isDone => _isDone;

  FutureTracker(Future? future) {
    if (future == null) {
      _isDone = true;
    } else {
      future.then((_) => _isDone = true).catchError((_) => _isDone = true); // Complete even on error}
    }
  }
}

class EasySEOController {
  // These are internal function pointers
  FutureOr<EasySEOGenerationResult?> Function()? _onGenerate;
  bool Function()? _isReady;
  // void Function()? _onClear;

  // The State calls this to "register" its internal methods
  void _attach({
    required FutureOr<EasySEOGenerationResult?> Function() onGenerate,
    required bool Function()? isReady,
    // required void Function() onClear,
  }) {
    _onGenerate = onGenerate;
    _isReady = isReady;
    // _onClear = onClear;
  }

  // Public API
  FutureOr<EasySEOGenerationResult?> generate() async {
    if (_onGenerate == null) throw Exception("Controller not attached!");
    return await _onGenerate!();
  }

  bool isReady() {
    if (_isReady == null) throw Exception("Controller not attached!");
    return _isReady!();
  }

  // void clear() => _onClear?.call();
}

class EasySEO extends StatefulWidget {
  final Widget child;
  final bool disabled;
  final String title;
  final String? description;
  final List<EasySEOHeadTag> headTags;
  final SEOServiceInfo? serviceInfo;
  final List<String> includeGlobals;
  final Future? whenDone;
  final ChangeNotifier? generateOnChanged;

  const EasySEO({
    super.key,
    required this.child,
    required this.title,
    this.description,
    this.disabled = false,
    this.headTags = const [],
    this.serviceInfo,
    this.includeGlobals = const [],
    this.whenDone,
    this.generateOnChanged
  });

  @override
  State<EasySEO> createState() => _EasySEOState();
}

class _EasySEOState extends State<EasySEO> {
  final _processor = SEOWidgetTreeProcessor();
  late final EasySEOFileOutput _fileHandler;
  late final EasySEOLiveOutput _liveHandler;
  late final url_helper.URLHelper _urlHelper;
  late final EasySEOController _controller;
  late final FutureTracker whenDoneTracker;

  @override
  void initState() {
    super.initState();
    _controller = EasySEOController();
    _fileHandler = EasySEOFileOutput();
    _liveHandler = EasySEOLiveOutput();
    _urlHelper = url_helper.URLHelper();
    whenDoneTracker = FutureTracker(widget.whenDone);

    if (widget.generateOnChanged != null) {
      debugPrint("EasySEO: calling gen in generateOnChanged()");
      widget.generateOnChanged!.addListener(() => _generate());
    }

    // 1. Attach internal logic to the controller
    _controller._attach(
      onGenerate: _generateHTML,
      isReady: () => whenDoneTracker._isDone,
      // onClear: _internalClearLogic,
    );
    // 2. Register this instance with the global singleton
    // Because it's added last, it becomes the 'activeController'
    EasySEOConfig.instance.register(_getCurrentPath(), _controller);

    // Auto-trigger on mount for your bot
    _generate();
  }

  @override
  void dispose() {
    // 3. Clean up the registry to allow the previous page to regain authority
    EasySEOConfig.instance.unregister(_controller);
    super.dispose();
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
      debugPrint("EasySEO: calling gen in didUpdateWidget() because title changed");
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
    final fullUrl = _getCurrentUrl();
    if (fullUrl != null) {
      addTag(EasySEOLinkTag.canonical(fullUrl));
      addTag(EasySEOOgTag.url(fullUrl));
    }

    // --- AUTOMATIC LANGUAGE ALTERNATES ---
    final alternates = _getAlternateUrls();
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

  EasySEOGenerationResult? _generateHTML() {
    // do nothing if globally disabled
    if (!EasySEOConfig.instance.enabled.value) return null;
    // do nothing if locally disabled
    if (widget.disabled) return null;

    final rootElement = _findRootElement();
    if (rootElement == null) {
      debugPrint("EasySEO: rootElement is null, skipping generation");
      return null;
    }

    debugPrint("EasySEO: Starting generation for path: ${_getCurrentPath()}");
    final bodyContent = _processor.processWidgetTree(rootElement, widget.includeGlobals);

    // Use page metadata from EasySEO widget
    final metadata = SEOPageMetadata(headTags: _allTags);

    final metadataStr = metadata.generateMetadata();

    if (EasySEOConfig.instance.enableLiveOutput.value) {
      _liveHandler.injectToHead(metadataStr);
      _liveHandler.injectToBody(bodyContent);
    }

    if (EasySEOConfig.instance.enableFileOutput.value || EasySEOConfig.instance.onGenerate != null) {
      // Detect language from path for the <html> tag
      final currentPath = _getCurrentPath();
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

      var result = (
        fullHtml: fullHtml,
        currentLanguage: currentLang,
        path: currentPath,
        headContent: metadataStr,
        bodyContent: bodyContent
      );

      // Call the callback if provided
      if (!EasySEOConfig.instance.disableOnGenerate.value) {
        EasySEOConfig.instance.onGenerate?.call(result);
      }
      return result;
    }

    return null;
  }

  Element? _findRootElement() {
    final element = context as Element;
    return element;
  }

  String _getCurrentPath() {
    if (EasySEOConfig.instance.pathProvider != null) {
      final path = EasySEOConfig.instance.pathProvider!(context);
      if (path != null) return path;
    }
    return _urlHelper.getCurrentPath();
  }

  String? _getCurrentUrl() {
    if (EasySEOConfig.instance.urlProvider != null) {
      final url = EasySEOConfig.instance.urlProvider!(context);
      if (url != null) return url;
    }

    final baseUrl = EasySEOConfig.instance.baseUrl;
    if (baseUrl != null && baseUrl.isNotEmpty) {
      return EasySEOConfig.instance.formatFullUrl(_getCurrentPath());
    }

    return _urlHelper.rawCurrentUrl;
  }

  Map<String, String> _getAlternateUrls() {
    // If we have a path provider, we should use it for alternates too
    if (EasySEOConfig.instance.pathProvider != null) {
      return _urlHelper.getAlternateUrls(pathOverride: _getCurrentPath());
    }
    return _urlHelper.getAlternateUrls();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
