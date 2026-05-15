import 'dart:convert';
import 'package:flutter_easy_seo/flutter_easy_seo.dart';
import 'package:web/web.dart' as web;
import 'easy_seo_file_output_base.dart';

/// Handler for file system operations
class EasySEOFileOutput with EasySEOFileOutputBase {
  String getSanitizedPath() {
    // 1. Determine the raw route
    String rawPath = web.window.location.pathname;
    final String hash = web.window.location.hash;

    // 2. Handle Hash Strategy (#/about -> /about)
    if (rawPath == '/' && hash.startsWith('#/')) {
      rawPath = hash.replaceFirst('#', '');
    }

    // 3. Clean up query parameters
    if (rawPath.contains('?')) {
      rawPath = rawPath.split('?').first;
    }

    // 4. Normalize the path
    // Ensure it starts with / but doesn't end with / for consistent processing
    if (!rawPath.startsWith('/')) rawPath = '/$rawPath';
    if (rawPath.endsWith('/') && rawPath.length > 1) {
      rawPath = rawPath.substring(0, rawPath.length - 1);
    }

    // 5. Convert to Directory Index Style
    // / -> index.html
    // /about -> about/index.html
    // /products/shoes -> products/shoes/index.html

    if (rawPath == '/') {
      return 'index.html';
    } else {
      // Remove the leading slash so the server treats it as a relative path
      String folderPath = rawPath.substring(1);
      return '$folderPath/index.html';
    }
  }

  static bool _sitemapSaved = false;

  void saveSitemapFile() {
    if (_sitemapSaved) return;

    final content = EasySEOConfig.instance.generateSitemapContent();
    if (content.isEmpty) return;

    _downloadFile(content, 'sitemap.xml', 'text/xml');
    _sitemapSaved = true;
    print('Generated sitemap.xml');
  }

  void _downloadFile(String content, String fileName, String contentType) {
    try {
      final encoded = base64Encode(utf8.encode(content));
      final dataUrl = 'data:$contentType;base64,$encoded';

      final anchor = web.HTMLAnchorElement()
        ..href = dataUrl
        ..download = fileName;

      web.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
    } catch (e) {
      print('Error downloading $fileName: $e');
    }
  }

  /// Save HTML content to a file (web: auto-download using data URL)
  @override
  void saveHTMLFile(String htmlContent) {
    // Automatically generate sitemap once per session if file output is enabled
    saveSitemapFile();

    final fileName = getSanitizedPath();
    try {
      // format html for better human readability
      var formattedHtmlContent = formatHtml(htmlContent);
      _downloadFile(formattedHtmlContent, fileName, 'text/html');
      print('Saved HTML file: $fileName');
    } catch (e) {
      print('Error saving HTML file: $e');
    }
  }
}
