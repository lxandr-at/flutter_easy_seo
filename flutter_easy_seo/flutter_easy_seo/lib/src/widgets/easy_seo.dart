part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOPageController {
  FutureOr<EasySEOGenerationResult> Function()? _onGenerate;
  bool _isReady = true;

  // The State calls this to "register" its internal methods
  void _attach({
    required FutureOr<EasySEOGenerationResult> Function() onGenerate,
  }) {
    _onGenerate = onGenerate;
  }

  void _setReady(bool ready) => _isReady = ready;

  // Public API
  FutureOr<EasySEOGenerationResult> generate() async {
    if (_onGenerate == null) return SeoFailure("Controller generate() not attached to an EasySEOPage function!");
    return await _onGenerate!();
  }

  bool isReady() => _isReady;
}

class EasySEOPage extends StatefulWidget {
  final Widget child;
  final bool disabled;
  final String title;
  final String? description;
  final List<EasySEOHeadTag> headTags;
  final SEOServiceInfo? serviceInfo;
  final List<String> includeGlobals;
  final Future? whenDone;
  final ChangeNotifier? generateOnChanged;

  const EasySEOPage(
      {super.key,
      required this.child,
      required this.title,
      this.description,
      this.disabled = false,
      this.headTags = const [],
      this.serviceInfo,
      this.includeGlobals = const [],
      this.whenDone,
      this.generateOnChanged});

  @override
  State<EasySEOPage> createState() => _EasySEOPageState();
}

class _EasySEOPageState extends State<EasySEOPage> {
  final _processor = SEOWidgetTreeProcessor();
  late final EasySEOFileOutput _fileHandler;
  late final EasySEOLiveOutput _liveHandler;
  late final url_helper.URLHelper _urlHelper;
  late final EasySEOPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasySEOPageController();
    _fileHandler = EasySEOFileOutput();
    _liveHandler = EasySEOLiveOutput();
    _urlHelper = url_helper.URLHelper();
    if (widget.whenDone != null) {
      _controller._setReady(false);
      widget.whenDone!.whenComplete(() => _controller._setReady(true));
    }

    if (widget.generateOnChanged != null) {
      debugPrint("EasySEO: calling gen in generateOnChanged()");
      widget.generateOnChanged!.addListener(() => _generate());
    }

    // register this state method with the controller so that
    // the EasySEOManager can call it
    _controller._attach(
      onGenerate: _generateHTML,
    );
    // 2. Register this instance with the global singleton
    // Because it's added last, it becomes the 'activeController'
    EasySEOManager.instance.register(_getCurrentPath(), _controller);

    // auto-generate on mount
    _generate();
  }

  @override
  void dispose() {
    // 3. Clean up the registry to allow the previous page to regain authority
    EasySEOManager.instance.unregister(_controller);
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
  void didUpdateWidget(EasySEOPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.title != oldWidget.title) {
      debugPrint("EasySEO: calling gen in didUpdateWidget() because title changed");
      _generate();
    }
  }

  /// Combines the explicit head tags (title, description, ...) with the user defined
  /// global and page level head tags and returns a list without duplicates.
  List<EasySEOHeadTag> get _allDistinctHeadTags {
    // Using a Map ensures that only one tag per "key" exists.
    final Map<String, EasySEOHeadTag> distinctHeadTags = {};
    void addTag(EasySEOHeadTag tag) {
      // local function
      distinctHeadTags[tag.key] = tag;
    }

    // default title and description tags
    String currentTitle = widget.title;
    addTag(EasySEOTitleTag(currentTitle));
    addTag(EasySEOMetaTag.title(currentTitle));
    addTag(EasySEOOgTag.title(currentTitle));
    addTag(EasySEOTwitterTag.title(currentTitle));
    if (widget.description != null) {
      addTag(EasySEOMetaTag.description(widget.description!));
      addTag(EasySEOOgTag.description(widget.description!));
      addTag(EasySEOTwitterTag.description(widget.description!));
    }

    // default url and alternate tags
    final currentPath = _getCurrentPath();
    final urls = EasySEOManager.instance.resolveSeoUrls(currentPath);
    final fullUrl = urls.canonicalUrl;

    addTag(EasySEOOgTag.url(fullUrl));
    addTag(EasySEOLinkTag.canonical(fullUrl));

    if (urls.alternateUrls.isNotEmpty) {
      urls.alternateUrls.forEach((lang, url) {
        addTag(EasySEOLinkTag.alternate(href: url, lang: lang));
      });
      if (urls.xDefaultUrl != null) {
        addTag(EasySEOLinkTag.alternate(href: urls.xDefaultUrl!, lang: 'x-default'));
      }
    }

    // add json-ld service tag if provided
    final serviceInfo = widget.serviceInfo ?? EasySEOManager.instance.serviceInfo;
    if (serviceInfo != null) {
      SEOServiceInfo finalInfo = serviceInfo;
      if (finalInfo.providerUrl == null) {
        finalInfo = finalInfo.copyWith(providerUrl: fullUrl);
      }
      addTag(EasySEOScriptTag(SEOHtmlJsonLd.service(finalInfo)));
    }

    // add or override global head tags
    for (var tag in EasySEOManager.instance.headTags) {
      addTag(tag);
    }
    // add or override head tags defined on the page level
    for (var tag in widget.headTags) {
      addTag(tag);
    }

    // return head tags without duplicates
    return distinctHeadTags.values.toList();
  }

  bool _isActiveController() {
    return EasySEOManager.instance.activeController == _controller;
  }

  EasySEOGenerationResult _generateHTML() {
    // do nothing if not the active (top level) EasySEOPage widget
    if (!_isActiveController()) {
      return SeoSkipped("not the active (top level) EasySEOPage widget");
    }
    // do nothing if globally or locally disabled
    if (!EasySEOManager.instance.enabled.value || widget.disabled) {
      return SeoSkipped(widget.disabled ? "Disabled locally" : "Disabled globally");
    }
    ;

    final rootElement = _findRootElement();
    if (rootElement == null) {
      return SeoMissingRoot("rootElement is null, skipping generation");
    }

    final bodyContent = _processor.processWidgetTree(rootElement, widget.includeGlobals);

    // Use page metadata from EasySEO widget
    final metadata = SEOPageMetadata(headTags: _allDistinctHeadTags);
    final headContent = metadata.generateMetadata();

    if (EasySEOManager.instance.enableLiveOutput.value) {
      _liveHandler.injectToHead(headContent);
      _liveHandler.injectToBody(bodyContent);
    }

    // Detect language from path for the <html> tag
    final currentPath = _getCurrentPath();
    final segments = currentPath.split('/');
    final supportedLanguages = EasySEOManager.instance.supportedLanguages;
    String currentLang = 'de'; // Default

    if (segments.length > 1 && supportedLanguages.contains(segments[1])) {
      currentLang = segments[1];
    } else if (supportedLanguages.isNotEmpty) {
      currentLang = supportedLanguages.first;
    }

    // generat full html page with head and body seo content
    final fullHtml = SEOHtmlDocumentGenerator.generateFullDocument(
      bodyContent: bodyContent,
      metadata: headContent,
      lang: currentLang,
    );

    bool fileOutputEnabled = EasySEOManager.instance.enableFileOutput.value;
    bool onGenerateOutputEnabled =
        EasySEOManager.instance.onGenerate != null && !EasySEOManager.instance.disableOnGenerate.value;

    var result = SeoSuccess(
        fullHtml: fullHtml,
        currentLanguage: currentLang,
        path: currentPath,
        headContent: headContent,
        bodyContent: bodyContent);
    // output as file download in the browser if enabled
    if (fileOutputEnabled) {
      _fileHandler.saveHTMLFile(fullHtml);
    }
    // push result to the onGenerate callback if provided and enabled
    if (onGenerateOutputEnabled) {
      EasySEOManager.instance.onGenerate?.call(result);
    }
    return result;
  }

  Element? _findRootElement() {
    final element = context as Element;
    return element;
  }

  String _getCurrentPath() {
    if (EasySEOManager.instance.pathProvider != null) {
      final path = EasySEOManager.instance.pathProvider!(context);
      if (path != null) return path;
    }
    return _urlHelper.getCurrentPath();
  }

  String? _getCurrentUrl() {
    if (EasySEOManager.instance.urlProvider != null) {
      final url = EasySEOManager.instance.urlProvider!(context);
      if (url != null) return url;
    }

    final baseUrl = EasySEOManager.instance.baseUrl;
    if (baseUrl != null && baseUrl.isNotEmpty) {
      return EasySEOManager.instance.formatFullUrl(_getCurrentPath());
    }

    return _urlHelper.rawCurrentUrl;
  }

  Map<String, String> _getAlternateUrls() {
    // If we have a path provider, we should use it for alternates too
    if (EasySEOManager.instance.pathProvider != null) {
      return _urlHelper.getAlternateUrls(pathOverride: _getCurrentPath());
    }
    return _urlHelper.getAlternateUrls();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
