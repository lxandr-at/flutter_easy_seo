mixin URLHelperBase {

  /// Platform-specific implementation to get the raw path
  String get rawCurrentPath;

  /// Returns the current path (pathname).
  String getCurrentPath() => rawCurrentPath;

  /// Checks if a given [urlPath] matches a [pattern] (e.g., 'compare/:productId').
  ///
  /// Automatically handles trailing slashes, leading slashes, and ignores
  /// query parameters or fragments.
  bool isPathMatch(String urlPath, String pattern) {
    // 1. Edge Case: Clean up query parameters or fragments if present (e.g., /compare/123?ref=search)
    final cleanPath = Uri.parse(urlPath).path;

    // 2. Normalize both paths by stripping leading/trailing slashes for uniform comparison
    final normalizedPattern = _normalizePath(pattern);
    final normalizedPath = _normalizePath(cleanPath);

    // 3. Convert the pattern into a strict RegExp.
    // This replaces segments starting with ':' (like ':productId') with a wildcard matcher '[^/]+'
    // which matches exactly one path segment.
    final regexPattern = normalizedPattern.split('/').map((segment) {
      if (segment.startsWith(':')) {
        return '[^/]+'; // Matches any character except a forward slash
      }
      return RegExp.escape(segment); // Escape static segments to prevent regex injection
    }).join('/');

    // 4. Enforce strict start (^) and end ($) anchors to prevent false partial matches
    final regExp = RegExp('^$regexPattern\$');

    return regExp.hasMatch(normalizedPath);
  }

  /// Removes leading and trailing slashes to ensure consistent matching
  String _normalizePath(String path) {
    var normalized = path.trim();
    if (normalized.startsWith('/')) normalized = normalized.substring(1);
    if (normalized.endsWith('/')) normalized = normalized.substring(0, normalized.length - 1);
    return normalized;
  }
}
