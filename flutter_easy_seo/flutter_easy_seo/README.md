# flutter_easy_seo

A Flutter package for generating SEO-friendly HTML from widget trees for search engine bots.

## Features

- Generate complete HTML documents from Flutter widget trees
- Automatic semantic HTML mapping (Text → h1-h6/p, Container → div/section/article, etc.)
- Scaffold extension for page-level SEO metadata
- Widget extension methods for easy SEO tagging
- Automatic sitemap.xml and robots.txt generation
- Directory structure matching your site routes
- Support for social media tags (Twitter, Open Graph) and custom meta tags

## Installation

Add `flutter_easy_seo` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_easy_seo: ^0.0.1
```

## Usage

### Basic Setup

Wrap your app with `SEOHtmlGenerator`:

```dart
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
  runApp(
    SEOHtmlGenerator(
      enabled: true, // Enable for SEO generation
      outputPath: 'seo-output/', // Output directory
      child: MyApp(),
    ),
  );
}
```

### Adding SEO to Pages

Use the `seo()` extension on Scaffold for page metadata:

```dart
Scaffold(
  appBar: AppBar(title: Text('My Page')),
  body: Center(
    child: Text('Hello World').seo(tag: 'h1'),
  ),
).seo(
  title: 'My Page Title',
  description: 'Page description for SEO',
  canonicalUrl: 'https://yoursite.com/my-page',
  additionalTags: {
    'twitter:card': 'summary_large_image',
    'og:title': 'My Page Title',
  },
);
```

### Widget SEO Extensions

Add SEO to individual widgets:

```dart
// Text widgets
Text('Page Heading').seo(tag: 'h1');
Text('Paragraph text').seo(tag: 'p');

// Container widgets
Container(
  child: Text('Section content'),
).seo(tag: 'section');

// Custom widgets
ProductGridWidget().seo(
  builder: (context, child) {
    return SEOContainerWrapper(
      tag: 'section',
      child: child,
    );
  }
);
```

## Output

The package generates:
- Complete HTML files for each route
- `sitemap.xml` with all page URLs
- `robots.txt` pointing to the sitemap
- Directory structure matching your site routes

## Architecture

This package uses Dart's `part`/`part of` directive system to share a single library namespace across all extensions and wrappers. This approach resolves Dart's type inference ambiguity when extensions with the same method name (`.seo()`) are applied to the same class (`Scaffold`).

### Why part/part of?

Dart's extension methods can shadow each other when imported separately. By consolidating all extensions into one library via `part` directives, the package ensures:
- Extensions for `Scaffold`, `Text`, `Container`, and custom widgets share the same namespace
- No ambiguity in method resolution
- Consistent `.seo()` API across all widget types

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

MIT License