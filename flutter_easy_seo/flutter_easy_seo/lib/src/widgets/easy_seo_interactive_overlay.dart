part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class EasySEOInteractiveOverlay extends StatelessWidget {
  const EasySEOInteractiveOverlay({super.key});

  void _showResultDialog(
    BuildContext context,
    String title,
    String content,
    String fileName,
    String contentType,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final scrollController = ScrollController();
        final showDownloadButton = !EasySEOManager.instance.enableFileOutput.value;

        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF333333), width: 1.5),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Scrollbar(
                      controller: scrollController,
                      thickness: 8.0,
                      radius: const Radius.circular(4),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 0),
                          child: SelectableText(
                            content,
                            style: const TextStyle(
                              color: Color(0xFFE0E0E0),
                              fontFamily: 'Courier',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showDownloadButton) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D2FF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          final fileHandler = EasySEOFileOutput();
                          if (fileName == 'sitemap.xml') {
                            fileHandler.saveSitemap(content);
                          } else {
                            fileHandler.saveHTMLFile(content);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(Icons.download_done, color: Colors.greenAccent),
                                  SizedBox(width: 8),
                                  Text('File download triggered!'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF1E1E1E),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.file_download, size: 18),
                        label: const Text(
                          'Download',
                          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.check_circle, color: Colors.greenAccent),
                                SizedBox(width: 8),
                                Text('Copied to clipboard!'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1E1E1E),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text(
                        'Copy All',
                        style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = EasySEOManager.instance;
    return AnimatedBuilder(
      animation: Listenable.merge([
        manager.disableOnGenerate,
        manager.enableLiveOutput,
        manager.enableFileOutput,
        manager.showResultDialog,
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Elegant responsive separator
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
                            if (result case SeoSuccess(:final fullHtml)) {
                              if (manager.showResultDialog.value) {
                                final fileHandler = EasySEOFileOutput();
                                _showResultDialog(
                                  context,
                                  'Generated HTML Page',
                                  fullHtml,
                                  fileHandler.getSanitizedPath(),
                                  'text/html',
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
                              _showResultDialog(
                                context,
                                'Generated sitemap.xml',
                                sitemap,
                                'sitemap.xml',
                                'text/xml',
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
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: value ? const Color(0xFF00D2FF).withAlpha(38) : Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: value ? const Color(0xFF00D2FF).withAlpha(102) : Colors.white.withAlpha(20),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: value ? const Color(0xFF00D2FF) : Colors.white60,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: value ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
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
