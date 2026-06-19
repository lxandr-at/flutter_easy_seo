import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';

class PlatformHelper {
  static String? get host => web.window.location.host;
  static String? get protocol => web.window.location.protocol;
  static bool get isWeb => kIsWeb;
  static bool get isTest => false;
  static bool get isWebOrTest => isWeb || isTest;
}
