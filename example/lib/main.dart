import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App(initialLocale: 'de'));
}
