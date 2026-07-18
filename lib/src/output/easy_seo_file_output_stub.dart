import 'package:flutter/foundation.dart';
import 'easy_seo_file_output_base.dart';

class EasySEOFileOutput with EasySEOFileOutputBase {
  @override
  String getSanitizedPath() => 'index.html';

  @override
  void saveHTMLFile(String htmlContent) {
    // Do nothing, or print a warning: "Save not supported on this platform"
    if (kDebugMode) {
      print('saveHTMLFile is only supported on Web');
    }
  }

  @override
  void saveSitemap(String sitemapContent) {
    if (kDebugMode) {
      print('saveSitemap is only supported on Web');
    }
  }
}
