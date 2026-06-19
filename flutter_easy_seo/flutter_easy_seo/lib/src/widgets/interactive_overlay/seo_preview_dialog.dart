part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

class _SeoPreviewDialog extends StatefulWidget {
  final String title;
  final String fileName;
  final SeoSuccess initialResult;

  const _SeoPreviewDialog({
    required this.title,
    required this.initialResult,
    required this.fileName,
  });

  @override
  State<_SeoPreviewDialog> createState() => _SeoPreviewDialogState();
}

class _SeoPreviewDialogState extends State<_SeoPreviewDialog> {
  late SEORenderMode _selectedMode;
  late SeoSuccess _currentResult;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = EasySEOManager.instance.renderMode.value;
    _currentResult = widget.initialResult;
  }

  Future<void> _onModeChanged(SEORenderMode mode) async {
    if (mode == _selectedMode) return;
    _selectedMode = mode;
    setState(() => _isRegenerating = true);
    final result = await EasySEOManager.instance.generateActive(mode: mode);
    if (mounted && result is SeoSuccess) {
      setState(() {
        _currentResult = result;
        _isRegenerating = false;
      });
    } else if (mounted) {
      setState(() => _isRegenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return _SeoDialog(
      title: widget.title,
      modeSelector: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: SEORenderMode.values.map((mode) => _buildModeChip(mode)).toList(),
      ),
      content: _isRegenerating
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FF)))
          : _SeoCodeDisplay(text: _currentResult.fullHtml, scrollController: scrollController),
      actions: [_SeoDialogActions(content: _currentResult.fullHtml, fileName: widget.fileName)],
    );
  }

  Widget _buildModeChip(SEORenderMode mode) {
    final isSelected = mode == _selectedMode;
    final label = _seoRenderModeLabels[mode] ?? mode.name;
    return _SeoChip(
      label: label,
      isSelected: isSelected,
      onTap: _isRegenerating ? null : () => _onModeChanged(mode),
      tooltip: 'Switch to $label mode',
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}
