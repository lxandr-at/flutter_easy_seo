part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOPageController {
  FutureOr<EasySEOGenerationResult> Function({SEORenderMode? mode})? _onGenerate;
  bool _isReady = true;

  // The State calls this to "register" its internal methods
  void _attach({
    required FutureOr<EasySEOGenerationResult> Function({SEORenderMode? mode}) onGenerate,
  }) {
    _onGenerate = onGenerate;
  }

  void _setReady(bool ready) => _isReady = ready;

  // Public API
  FutureOr<EasySEOGenerationResult> generate({SEORenderMode? mode}) async {
    if (_onGenerate == null) return SeoFailure("Controller generate() not attached to an EasySEOPage function!");
    return await _onGenerate!(mode: mode);
  }

  bool isReady() => _isReady;
}

/// A widget that manages SEO metadata, dynamic tag insertion, and HTML output generation for a specific page.
///
/// `EasySEOPage` wraps a page's widget tree, analyzes its content dynamically, resolves
/// canonical and alternate URLs, and compiles the result into a fully semantic HTML structure.
///
/// ### Parameters:
/// * [child] - The widget tree of the page content to render and inspect.
/// * [title] - The canonical page title, which automatically generates `<title>`, `og:title`,
///   `twitter:title`, and `name="title"` metadata tags.
/// * [description] - An optional page description, which automatically constructs `description`,
///   `og:description`, and `twitter:description` metadata tags.
/// * [disabled] - When set to `true`, disables SEO generation locally for this specific page.
/// * [headTags] - Custom page-level tags or sources ([EasySEOHeadTagSource]) to inject into the document `<head>`, overriding globals.
/// * [includeGlobals] - Widgets with these [EasySEOBaseWrapper.globalName] ids are added to the `<body>` tag. Widgets like header, footer
/// or navigation may be outside of the widget tree of the [child] widget. For example, when using a [ShellRouter] only the main
/// content is wrapped in an EasySEOPage widget. Header, footer and navigation are outside and get a [EasySEOBaseWrapper.globalName] id. When
/// added to the [includeGlobals] list, these widget are also contained in the generated SEO html page.
/// * [whenDone] - An optional async callback hook executed before HTML page generation to ensure all async state (e.g., loading data) is resolved.
/// For example, waiting for a Riverpod provider that loads product data for a products overview page could look like this:
/// ```dart
/// whenDone: () async => await ref.read(productsProvider.future)
/// ```
/// * [rank] - Numeric rank value used by [EasySEOManager] to determine the active [EasySEOPage] when more than one exists in the current widget tree.
/// For example, this is the case when the products overview page shows the product details in a modal dialog. Both, the list in the background and
/// the details dialog are wrapped in a [EasySEOManager] with rank: 0 and rank: 1 respectively to avoid ambiguity when the [EasySEOManager] determines
/// the active [EasySEOPage] from the current path depth and length.
/// * [renderMode] - [SEORenderMode] configuration to override the global rendering mode.
class EasySEOPage extends StatefulWidget {
  final Widget child;
  final bool disabled;
  final String title;
  final String? description;
  final List<EasySEOHeadTagSource> headTags;
  final List<String> includeGlobals;
  final Future<void> Function()? whenDone;
  final int rank;
  final SEORenderMode? renderMode;

  const EasySEOPage({super.key,
    required this.child,
    required this.title,
    this.description,
    this.disabled = false,
    this.headTags = const [],
    this.includeGlobals = const [],
    this.whenDone,
    this.rank = 0,
    this.renderMode,
  });

  @override
  State<EasySEOPage> createState() => _EasySEOPageState();
}

class _EasySEOPageState extends State<EasySEOPage> {
  final _processor = SEOWidgetTreeProcessor();
  late final EasySEOFileOutput _fileHandler;
  late final EasySEOLiveOutput _liveHandler;
  late final url_helper.URLHelper _urlHelper;
  late final EasySEOPageController _controller;
  SeoRouteKey? _currentRouteKey;

  @override
  void initState() {
    super.initState();
    _controller = EasySEOPageController();
    _fileHandler = EasySEOFileOutput();
    _liveHandler = EasySEOLiveOutput();
    _urlHelper = url_helper.URLHelper();

    // register this state method with the controller so that
    // the EasySEOManager can call it
    _controller._attach(
      onGenerate: _generateHTML,
    );
    // registering with EasySEOManager is done in build()
    // because the context at this point gets the old route path

    _initSEO();
  }

  Future<void> _initSEO() async {
    if (widget.whenDone != null) {
      _controller._setReady(false);
      await widget.whenDone!();
      _controller._setReady(true);
    }

    // auto-generate on mount
    _generate();
  }

  @override
  void dispose() {
    // 3. Clean up the registry to allow the previous page to regain authority
    if (_currentRouteKey != null) {
      EasySEOManager.instance.unregister(_currentRouteKey!);
    }
    super.dispose();
  }

  void _generate() async {
    if (widget.whenDone != null) {
      await widget.whenDone!();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        debugPrint("EasySEO: calling gen in initState() after whenDone");
        _generateHTML();
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

    // default url and alternate tags
    final currentPath = _getCurrentPath();
    final urls = EasySEOManager.instance.resolveSeoUrls(currentPath);
    final fullUrl = urls.canonicalUrl;
    addTag(EasySEOLinkTag.canonical(fullUrl));

    for (final tag in EasySEOOgTags(title: currentTitle, url: fullUrl, description: widget.description).toHeadTags()) {
      addTag(tag);
    }
    for (final tag in EasySEOTwitterTags(title: currentTitle, description: widget.description).toHeadTags()) {
      addTag(tag);
    }
    if (widget.description != null) {
      addTag(EasySEOMetaTag.description(widget.description!));
    }

    if (urls.alternateUrls.isNotEmpty) {
      urls.alternateUrls.forEach((lang, url) {
        addTag(EasySEOLinkTag.alternate(href: url, lang: lang));
      });
      if (urls.xDefaultUrl != null) {
        addTag(EasySEOLinkTag.alternate(href: urls.xDefaultUrl!, lang: 'x-default'));
      }
    }

    // flatten all head tag sources (global + page level)
    for (final source in [
      ...EasySEOManager.instance.headTags,
      ...widget.headTags,
    ]) {
      final resolved = (source is SEOServiceInfo && source.providerUrl == null)
          ? source.copyWith(providerUrl: fullUrl)
          : source;
      for (final tag in resolved.toHeadTags()) {
        addTag(tag);
      }
    }

    // return head tags without duplicates
    return distinctHeadTags.values.toList();
  }

  bool _isActiveController() {
    return EasySEOManager.instance.activeController == _controller;
  }

  EasySEOGenerationResult _generateHTML({SEORenderMode? mode}) {
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

    final effectiveMode = mode ?? widget.renderMode ?? EasySEOManager.instance.renderMode.value;
    final bodyContent = _processor.processWidgetTree(rootElement, widget.includeGlobals, mode: effectiveMode);

    // Extract dynamic route URLs from generated HTML content and add them to gathered pages
    EasySEOManager.instance.gatherFromHtml(bodyContent);

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
    return EasySEOManager.instance.getCurrentPath(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: EasySEOManager.instance.enableInteractiveMode,
      builder: (context, enabled, child) {
        // 2. Register this instance with the global singleton
        // Because it's added last, it becomes the 'activeController'
        _currentRouteKey = SeoRouteKey(path: _getCurrentPath(), rank: widget.rank);
        EasySEOManager.instance.register(_currentRouteKey!, _controller);

        if (!enabled) return child!;
        return Stack(
          children: [
            child!,
            const Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Material(
                type: MaterialType.transparency,
                child: Center(
                  child: EasySEOInteractiveOverlay(),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
