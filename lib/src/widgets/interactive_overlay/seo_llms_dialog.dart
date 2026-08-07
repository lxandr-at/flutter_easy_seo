part of 'package:flutter_easy_seo/flutter_easy_seo.dart';

enum _LlmsFile { llmsTxt, llmsFullTxt }

const _llmsFileLabels = {
  _LlmsFile.llmsTxt: 'llms.txt',
  _LlmsFile.llmsFullTxt: 'llms-full.txt',
};

class _SeoLlmsDialog extends StatefulWidget {
  final String title;
  final String llmsTxt;
  final String llmsFullTxt;
  final VoidCallback? onClose;

  const _SeoLlmsDialog({
    required this.title,
    required this.llmsTxt,
    required this.llmsFullTxt,
    this.onClose,
  });

  @override
  State<_SeoLlmsDialog> createState() => _SeoLlmsDialogState();
}

class _SeoLlmsDialogState extends State<_SeoLlmsDialog> {
  _LlmsFile _selectedFile = _LlmsFile.llmsTxt;

  String get _currentContent => _selectedFile == _LlmsFile.llmsTxt
      ? widget.llmsTxt
      : widget.llmsFullTxt;

  String get _currentFileName => _llmsFileLabels[_selectedFile]!;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return _SeoDialog(
      onClose: widget.onClose,
      title: widget.title,
      modeSelector: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _LlmsFile.values.map((file) => _buildFileChip(file)).toList(),
      ),
      content: _SeoCodeDisplay(text: _currentContent, scrollController: scrollController),
      actions: [_SeoDialogActions(content: _currentContent, fileName: _currentFileName)],
    );
  }

  Widget _buildFileChip(_LlmsFile file) {
    final isSelected = file == _selectedFile;
    final label = _llmsFileLabels[file]!;
    return _SeoChip(
      label: label,
      isSelected: isSelected,
      onTap: () => setState(() => _selectedFile = file),
      tooltip: 'Show $label',
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}
