# flutter_easy_seo

A Flutter package that generates SEO-friendly HTML from the live widget tree for search engine bots.

## The Problem

- **Search Bots Need Text**: For a web application to rank, search engine bots must parse the site's textual and structural content.
- **Flutter is a Blank Canvas**: To a crawler, a baseline Flutter Web app looks like an empty page. Flutter does not use a document-based HTML DOM; instead, it paints pixels directly onto a single, flat ``<canvas>`` via CanvasKit or WebAssembly. 
- **No SSR or Hydration**: Standard architectural workarounds like Server-Side Rendering (SSR) or DOM hydration are fundamentally impossible within Flutter’s rendering pipeline.

## The Solution
This package implements a dual-layer strategy to bridge the Flutter-to-SEO gap completely:

1. **[Dynamic Rendering](https://developers.google.com/search/docs/crawling-indexing/javascript/dynamic-rendering) (Static File Serving)**: The package pre-generates your views into pure, static HTML files. When a search bot requests a page, your server instantly delivers this static file. Because it requires zero engine initialization, the bot gets the full text content instantly.
2. **Hybrid Live DOM Injection:** While the app runs for human users, the package actively injects the exact same semantic HTML directly into the browser DOM. 

   This serves as a critical fail-safe for two reasons:
   - **Anti-Cloaking Compliance:** Search engines like Google frequently run undercover audits using stealth, human-like user agents to verify that users see the same content as the bots. Live injection ensures your content remains identical across all testing profiles.
   - **Unknown Crawlers:** It provides a safe fallback for AI crawlers, scrapers, or third-party bots that do not announce themselves as a bot to your server, but still rely on reading a rendered HTML structure after execution.

## Main Features

- Generate complete HTML documents from the Flutter live widget tree
- Automatic sitemap.xml generation
- Supports SEO-relevant html tags and head section info and meta data (Twitter, Open Graph) and custom meta tags
- Interactive mode with UI overlay
- Automatic mode via flutter widget tester
- json+ld and microdata support

## Installation

Add `flutter_easy_seo` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_easy_seo: ^0.0.1
```

## Architecture Overview

![Easy SEO Architecture Overview](./docs/images/architecture_overview.png)

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
- Directory structure matching your site routes

## License

MIT License