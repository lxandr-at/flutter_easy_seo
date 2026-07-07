part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

const _seoRenderModeLabels = {
  SEORenderMode.htmlOnly: 'HTML Only',
  SEORenderMode.microdata: 'Microdata',
  SEORenderMode.jsonLdOnly: 'JSON-LD Only',
  SEORenderMode.full: 'Full',
  SEORenderMode.microdataAndJsonLd: 'Microdata+JSON-LD',
};

class _SeoSnackbar {
  static void show(BuildContext context, {required String message, required IconData icon, Color? iconColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.greenAccent),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _SeoChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;

  const _SeoChip({
    required this.label,
    this.icon,
    required this.isSelected,
    this.onTap,
    this.tooltip,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00D2FF).withAlpha(38) : Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF00D2FF).withAlpha(102) : Colors.white.withAlpha(20),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(icon, color: isSelected ? const Color(0xFF00D2FF) : Colors.white60, size: 14),
            ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
    final wrapped = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: chip,
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: wrapped);
    return wrapped;
  }
}

class _SeoCodeDisplay extends StatelessWidget {
  final String text;
  final ScrollController scrollController;

  const _SeoCodeDisplay({
    required this.text,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: RawScrollbar(
        controller: scrollController,
        thickness: 8.0,
        radius: const Radius.circular(4),
        thumbColor: Colors.white.withAlpha(128),
        minThumbLength: 40,
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 0),
            child: SelectableText(
              text,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontFamily: 'Courier',
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeoDialogActions extends StatelessWidget {
  final String content;
  final String fileName;

  const _SeoDialogActions({
    required this.content,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final showDownload = !EasySEOManager.instance.enableFileOutput.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showDownload) ...[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D2FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              final fileHandler = EasySEOFileOutput();
              if (fileName == 'sitemap.xml') {
                fileHandler.saveSitemap(content);
              } else {
                fileHandler.saveHTMLFile(content);
              }
              _SeoSnackbar.show(context,
                message: 'File download triggered!',
                icon: Icons.download_done,
              );
            },
            icon: const Icon(Icons.file_download, size: 18),
            label: const Text('Download', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
        ],
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: content));
            _SeoSnackbar.show(context,
              message: 'Copied to clipboard!',
              icon: Icons.check_circle,
            );
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy All', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _SeoDialog extends StatelessWidget {
  final String title;
  final Widget? modeSelector;
  final Widget content;
  final List<Widget> actions;
  final VoidCallback? onClose;

  const _SeoDialog({
    required this.title,
    this.modeSelector,
    required this.content,
    required this.actions,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
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
                Text(title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: onClose,
                ),
              ],
            ),
            if (modeSelector != null) ...[
              const SizedBox(height: 12),
              modeSelector!,
            ],
            const SizedBox(height: 16),
            Expanded(child: content),
            const SizedBox(height: 16),
            ...actions,
          ],
        ),
      ),
    );
  }
}
