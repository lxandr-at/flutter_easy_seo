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

  /// Generate sitemap.xml content
  String generateSitemapContent() {
    final config = EasySEOConfig.instance;
    final baseUrl = config.baseUrl;
    if (baseUrl == null || baseUrl.isEmpty) return '';

    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final langs = config.supportedLanguages;
    final pages = config.pages.isEmpty ? [''] : config.pages;

    final StringBuffer sitemap = StringBuffer();
    sitemap.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sitemap.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"');
    sitemap.writeln('        xmlns:xhtml="http://www.w3.org/1999/xhtml">');

    // x-default typically points to the first supported language or a neutral version
    final String? firstLang = langs.isNotEmpty ? langs.first : null;

    for (final page in pages) {
      // Normalize page path
      String cleanPage = page.trim();
      if (cleanPage.isNotEmpty && !cleanPage.startsWith('/')) {
        cleanPage = '/$cleanPage';
      }
      if (cleanPage == '/') cleanPage = '';

      // Determine priority based on page name
      String priority = "0.8";
      if (cleanPage.contains('offers') || cleanPage.isEmpty) {
        priority = "1.0";
      } else if (cleanPage.contains('compare')) {
        priority = "0.8";
      }

      // If no languages, just output the neutral page
      if (langs.isEmpty) {
        final displayLoc = cleanPage.isEmpty ? '$cleanBase/' : '$cleanBase$cleanPage';
        sitemap.writeln('  <url>');
        sitemap.writeln('    <loc>$displayLoc</loc>');
        sitemap.writeln('    <priority>$priority</priority>');
        sitemap.writeln('    <changefreq>daily</changefreq>');
        sitemap.writeln('  </url>');
        continue;
      }

      // Exhaustive loop for every language/page combination
      for (final currentLang in langs) {
        final displayLoc = '$cleanBase/$currentLang$cleanPage';

        sitemap.writeln('  <url>');
        sitemap.writeln('    <loc>$displayLoc</loc>');

        // Every entry includes alternates for ALL languages
        for (final altLang in langs) {
          final altUrl = '$cleanBase/$altLang$cleanPage';
          sitemap.writeln('    <xhtml:link rel="alternate" hreflang="$altLang" href="$altUrl"/>');
        }

        // Add x-default pointing to the first language
        if (firstLang != null) {
          final defaultUrl = '$cleanBase/$firstLang$cleanPage';
          sitemap.writeln('    <xhtml:link rel="alternate" hreflang="x-default" href="$defaultUrl"/>');
        }

        sitemap.writeln('    <priority>$priority</priority>');
        sitemap.writeln('    <changefreq>daily</changefreq>');
        sitemap.writeln('  </url>');
      }
    }

    sitemap.writeln('</urlset>');
    return sitemap.toString();
  }

  void saveSitemapFile() {
    if (_sitemapSaved) return;

    final content = generateSitemapContent();
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
