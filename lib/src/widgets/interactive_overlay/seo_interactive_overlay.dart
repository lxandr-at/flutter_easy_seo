part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOInteractiveOverlay extends StatefulWidget {
  const EasySEOInteractiveOverlay({super.key});

  @override
  State<EasySEOInteractiveOverlay> createState() => _EasySEOInteractiveOverlayState();
}

class _EasySEOInteractiveOverlayState extends State<EasySEOInteractiveOverlay> {
  late bool _isMinimized;

  @override
  void initState() {
    super.initState();
    _isMinimized = EasySEOManager.instance._interactiveMinimized;
    _reportSize();
  }

  void _reportSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final size = renderBox.size;
        final manager = EasySEOManager.instance;
        if (manager._panelSize.value != size) {
          manager._panelSize.value = size;
        }
      }
    });
  }

  void _startDrag() {
    final manager = EasySEOManager.instance;
    if (manager._panelPosition.value == null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        manager._panelPosition.value = renderBox.localToGlobal(Offset.zero);
      }
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final manager = EasySEOManager.instance;
    final current = manager._panelPosition.value;
    if (current != null) {
      manager._panelPosition.value = Offset(
        current.dx + details.delta.dx,
        current.dy + details.delta.dy,
      );
    }
  }

  void _showSitemapDialog(
    BuildContext context,
    String title,
    String content,
    String fileName,
  ) {
    final panelEntry = EasySEOManager.instance._panelOverlayEntry;
    if (panelEntry == null) return;

    final scrollController = ScrollController();
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (_) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) entry?.remove();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => entry?.remove(),
                child: Container(color: Colors.black54),
              ),
            ),
            Center(
              child: _SeoDialog(
                title: title,
                content: _SeoCodeDisplay(text: content, scrollController: scrollController),
                actions: [_SeoDialogActions(content: content, fileName: fileName)],
                onClose: () => entry?.remove(),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insertAll([entry], above: panelEntry);
  }

  void _showHtmlPreviewDialog(
    BuildContext context,
    String title,
    SeoSuccess result,
    String fileName,
  ) {
    final panelEntry = EasySEOManager.instance._panelOverlayEntry;
    if (panelEntry == null) return;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (_) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) entry?.remove();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => entry?.remove(),
                child: Container(color: Colors.black54),
              ),
            ),
            Center(
              child: _SeoPreviewDialog(
                title: title,
                initialResult: result,
                fileName: fileName,
                onClose: () => entry?.remove(),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insertAll([entry], above: panelEntry);
  }

  Widget _buildMinimized(BuildContext context) {
    return Tooltip(
      message: 'Expand EasySEO Overlay',
      child: GestureDetector(
        onTap: () => setState(() {
          _isMinimized = false;
          EasySEOManager.instance._interactiveMinimized = false;
        }),
        onPanStart: (_) => _startDrag(),
        onPanUpdate: (details) => _onDragUpdate(details),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2C3E50), Color(0xFF0F2027)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(128),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.white.withAlpha(38),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.troubleshoot,
            color: Color(0xFF00D2FF),
            size: 26,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _reportSize();
    if (_isMinimized) {
      return _buildMinimized(context);
    }

    final manager = EasySEOManager.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([
        manager.disableOnGenerate,
        manager.enableLiveOutput,
        manager.enableFileOutput,
        manager.showResultDialog,
        manager.showHighlights,
      ]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;

            return Container(
              constraints: const BoxConstraints(maxWidth: 680),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF0F2027)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(128),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withAlpha(38),
                  width: 1.5,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 12 : 20,
                vertical: isNarrow ? 10 : 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Centered horizontal drag handle
                  Center(
                    child: GestureDetector(
                      onPanStart: (_) => _startDrag(),
                      onPanUpdate: (details) => _onDragUpdate(details),
                      child: Tooltip(
                        message: 'Drag to move',
                        child: Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(60),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Header Row with Title and Minimize Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.analytics, color: Color(0xFF00D2FF), size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'EasySEO Interactive Panel',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close_fullscreen, color: Colors.white70, size: 16),
                        tooltip: 'Minimize Panel',
                        onPressed: () => setState(() {
                          _isMinimized = true;
                          EasySEOManager.instance._interactiveMinimized = true;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Elegant separator
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withAlpha(20),
                  ),
                  const SizedBox(height: 12),
                  // Row 1: Settings Toggles
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildToggle(
                        label: 'Auto Gen',
                        value: !manager.disableOnGenerate.value,
                        icon: Icons.sync,
                        onChanged: (val) => manager.disableOnGenerate.value = !val,
                        tooltip: 'Automatically trigger SEO generation on page load',
                      ),
                      _buildToggle(
                        label: 'Live Out',
                        value: manager.enableLiveOutput.value,
                        icon: Icons.bolt,
                        onChanged: (val) => manager.enableLiveOutput.value = val,
                        tooltip: 'Inject SEO tags dynamically in DOM',
                      ),
                      _buildToggle(
                        label: 'File Out',
                        value: manager.enableFileOutput.value,
                        icon: Icons.file_download,
                        onChanged: (val) => manager.enableFileOutput.value = val,
                        tooltip: 'Automatically download generated HTML and sitemap files',
                      ),
                      _buildToggle(
                        label: 'Show Popup',
                        value: manager.showResultDialog.value,
                        icon: Icons.visibility,
                        onChanged: (val) => manager.showResultDialog.value = val,
                        tooltip: 'Show results popup dialog after generation',
                      ),
                      _buildToggle(
                        label: 'Highlights',
                        value: manager.showHighlights.value,
                        icon: Icons.border_style,
                        onChanged: (val) => manager.showHighlights.value = val,
                        tooltip: 'Show colored borders around SEO-wrapped widgets',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Elegant separator
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withAlpha(25),
                  ),
                  const SizedBox(height: 12),
                  // Row 2: Action Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildButton(
                        context: context,
                        label: 'Generate HTML',
                        icon: Icons.code,
                        onPressed: () async {
                          final result = await EasySEOManager.instance.generateActive();
                          if (context.mounted) {
                            if (result case SeoSuccess _) {
                              if (manager.showResultDialog.value) {
                                final fileHandler = EasySEOFileOutput();
                                _showHtmlPreviewDialog(
                                  context,
                                  'Generated HTML Page',
                                  result,
                                  fileHandler.getSanitizedPath(),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('HTML generated successfully!')),
                                );
                              }
                            } else if (result case SeoFailure(:final error)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Generation failed: $error')),
                              );
                            } else if (result case SeoSkipped(:final reason)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Generation skipped: $reason')),
                              );
                            } else if (result case SeoMissingRoot(:final message)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Missing root element: $message')),
                              );
                            }
                          }
                        },
                      ),
                      _buildButton(
                        context: context,
                        label: 'Generate Sitemap',
                        icon: Icons.account_tree,
                        onPressed: () {
                          final sitemap = EasySEOManager.instance.generateSitemapContent();
                          if (sitemap.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sitemap is empty. Check your baseUrl and pages!')),
                            );
                          } else {
                            if (manager.enableFileOutput.value) {
                              final fileHandler = EasySEOFileOutput();
                              fileHandler.saveSitemap(sitemap);
                            }
                            if (manager.showResultDialog.value) {
                              _showSitemapDialog(
                                context,
                                'Generated sitemap.xml',
                                sitemap,
                                'sitemap.xml'
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sitemap generated successfully!')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
    required String tooltip,
  }) {
    return _SeoChip(
      label: label,
      icon: icon,
      isSelected: value,
      onTap: () => onChanged(!value),
      tooltip: tooltip,
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF00D2FF), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }

}
