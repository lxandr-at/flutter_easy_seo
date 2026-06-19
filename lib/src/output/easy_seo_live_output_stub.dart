import 'package:flutter/foundation.dart' show kDebugMode;
import 'easy_seo_live_output_base.dart';

class EasySEOLiveOutput with EasySEOLiveOutputBase {
  @override
  void injectToHead(String htmlContent) {
    // Do nothing, or print a warning: "Save not supported on this platform"
    if (kDebugMode) {
      print('injectToHead is only supported on Web');
    }
  }

  @override
  void injectToBody(String htmlContent) {
    // Do nothing, or print a warning: "Save not supported on this platform"
    if (kDebugMode) {
      print('injectToBody is only supported on Web');
    }
  }
}
