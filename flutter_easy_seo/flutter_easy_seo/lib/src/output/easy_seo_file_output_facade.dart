// Export the stub version by default
export 'easy_seo_file_output_stub.dart'
    // If we are on the web, export the web version instead
    if (dart.library.js_interop) 'easy_seo_file_output_web.dart';
