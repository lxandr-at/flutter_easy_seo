mixin EasySEOFileOutputBase {
  // Shared logic: This works on all platforms!
  String formatHtml(String html) {
    int indentLevel = 0;
    final StringBuffer formatted = StringBuffer();
    final RegExp elementRegExp = RegExp(r'(<[^>]+>|[^<]+)');
    final Iterable<Match> matches = elementRegExp.allMatches(html);

    for (final match in matches) {
      String token = match.group(0)!.trim();
      if (token.isEmpty) continue;

      if (token.startsWith('</')) {
        indentLevel--;
        formatted.writeln('  ' * indentLevel + token);
      } else if (token.startsWith('<') && !token.endsWith('/>') && !token.startsWith('<!')) {
        formatted.writeln('  ' * indentLevel + token);
        // Don't indent for void elements like <img> or <meta>
        if (!RegExp(r'<(img|meta|br|hr|link|input)', caseSensitive: false).hasMatch(token)) {
          indentLevel++;
        }
      } else {
        formatted.writeln('  ' * indentLevel + token);
      }
    }
    return formatted.toString();
  }

  // This is the platform-specific bit
  void saveHTMLFile(String htmlContent);
}
