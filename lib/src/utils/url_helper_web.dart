import 'package:web/web.dart' as web;
import 'url_helper_base.dart';

class URLHelper with URLHelperBase {

  @override
  String get rawCurrentPath => web.window.location.pathname;
}
