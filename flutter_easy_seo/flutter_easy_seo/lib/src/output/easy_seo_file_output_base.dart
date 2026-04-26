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
  /// Generate sitemap.xml content
  String generateSitemapContent(List<String> urls) {
    final StringBuffer sitemap = StringBuffer();
    sitemap.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sitemap.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');

    for (final url in urls) {
      sitemap.writeln('  <url>');
      sitemap.writeln('    <loc>$url</loc>');
      sitemap.writeln('  </url>');
    }

    sitemap.writeln('</urlset>');
    return sitemap.toString();
  }

  /// Generate robots.txt content
  String generateRobotsContent(String sitemapUrl) {
    return '''
      User-agent: *
      Allow: /
      
      Sitemap: $sitemapUrl
    ''';
  }

  // This is the platform-specific bit
  void saveHTMLFile(String htmlContent);
}

