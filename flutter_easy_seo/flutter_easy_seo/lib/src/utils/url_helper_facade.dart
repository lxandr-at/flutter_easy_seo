// Export the stub version by default
export 'url_helper_stub.dart'
    // If we are on the web, export the web version instead
    if (dart.library.js_interop) 'url_helper_web.dart';
