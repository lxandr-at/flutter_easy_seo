import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformHelper {
  static String? get host => null;
  static String? get protocol => null;
  static bool get isWeb => kIsWeb;
  static bool get isTest => Platform.environment.containsKey('FLUTTER_TEST');
  static bool get isWebOrTest => isWeb || isTest;
}
