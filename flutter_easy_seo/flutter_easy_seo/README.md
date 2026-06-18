# flutter_easy_seo

A Flutter package that generates SEO-friendly HTML from the live widget tree for search engine bots.
1. **Initialize** `EasySEOManager` within your `main()` function.
2. **Wrap** the root of your target view with `EasySEOPage` to flag it for HTML generation.
3. **Expose** content to the HTML body by wrapping your UI elements with components 
like `EasySEOTextWrapper`, or by using their equivalent widget extension methods like `.easySeoText()`.
4. **Generate** HTML content, either interactively by clicking through your web app or automatically in 
a headless widget tester.
5. **Serve** these static HTML pages to search engine bots (and the flutter app to human users).

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
The architecture consists of 4 main parts:
- **EasySEOManger:** Singleton for orchestration and configuration.
- **EasySEOPage:** Wraps (part of) a widget tree to genearate an SEO-friendly html version.
- **Widget wrappers, HTML helper, etc.:** Create specific HMTL, jsonld and microdata output.
- **File generation:** Generate HTML and sitemap.xml files either interactively or automatically with a widget tester.

![Easy SEO Architecture Overview](./docs/images/architecture_overview.png)

## Simple Usage Example

1. **Initialize** `EasySEOManager` within your `main()` function.
2. **Wrap** the root of your target view with `EasySEOPage` to flag it for HTML generation.
3. **Expose** content to the HTML body by wrapping your layout elements with semantic components 
like `EasySEOTextWrapper`, or by using their equivalent widget extension methods like `.easySeoText()`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_easy_seo/flutter_easy_seo.dart';

void main() {
   // ... other code

   EasySEOManager.instance.init(
      enableInteractiveMode: kDebugMode, // enable interactive mode in debug mode
      enableLiveOutput: kDebugMode, // inject to DOM in debug mode
      baseUrl: "https://mysite.com",
   );
   runApp(const MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});

   @override
   Widget build(BuildContext context) {
      return const MaterialApp(
         home: Scaffold(
            body: EasySEOPage(
               title: 'Some Web Page',
               child: SizedBox.expand(
                  child: Center(
                     child: EasySEOTextWrapper(child: Text('Hello World')),
                  ),
               ),
            ),
         ),
      );
   }
}
```
This will generate the following HMTL and sitemap.xml:
```html
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title data-easy-seo="title">Some Web Page</title>
  <meta data-easy-seo="meta:name:title" name="title" content="Some Web Page">
  <link data-easy-seo="link:rel:canonical" rel="canonical" href="https://mysite.com/">
  <meta data-easy-seo="meta:property:og:title" property="og:title" content="Some Web Page">
  <meta data-easy-seo="meta:property:og:url" property="og:url" content="https://mysite.com/">
  <meta data-easy-seo="meta:name:twitter:card" name="twitter:card" content="summary_large_image">
  <meta data-easy-seo="meta:name:twitter:title" name="twitter:title" content="Some Web Page">
</head>
<body>
<p>Hello World</p>
</body>
</html>
```
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xhtml="http://www.w3.org/1999/xhtml">
  <url>
    <loc>https://mysite.com/</loc>
    <priority>1.0</priority>
    <changefreq>daily</changefreq>
  </url>
</urlset>
```

## Widget wrappers and HTML output
Although both Flutter and HTML rely on a tree structure to define content, a Flutter widget tree cannot be converted into an HTML document entirely automatically. To generate optimized SEO metadata, we must explicitly flag specific parts of the widget tree. This architectural approach is necessary for several reasons:

1. **SEO-Focused Filtering:** We only want to extract content that directly impacts search engine indexing and discoverability.
2. **Structural Mismatches:** Many Flutter layout widgets lack a meaningful HTML equivalent. While structural components like `Center` or `Padding` are essential for a full visual CSS layout, they serve no purpose in an SEO-friendly, text-first HTML document.
3. **Contextual Layout Mapping:** A single Flutter widget can represent entirely different semantic HTML elements depending on its context. For example, a `Row` of images could map to a site `<header>` containing an `<h1>` and `<a>` tags, or it could simply translate to a standard `<div>` containing `<img>` elements.

Note: For some flutter widgets the html content can be automatically extracted:
- **`Text()`**: `easySeoP` and `easySeoH1..H6` automatically extract the text content
- **`Image.network`**: `easySeo` automatically extracts the `src`

### Custom output defintion with core classes

At the core of this mapping system are the **SEOHtml** class and its derived elements, which allow you to define any custom HTML tree. While these are used automatically by our widget wrappers, you can also use them directly if the built-in extensions and helper methods don't fit your needs. For example, if the `EasySEOFaqWrapper` weren't available, you could build a custom FAQ structure like this:
```dart
Column(
  children: [
    Text('Frequently Asked Questions'),
    Text('Q1: How does this work?'),
    Text('A1: It generates HTML from the widget tree.'),
    Text('Q2: Is it fast?'),
    Text('A2: Yes, it runs asynchronously.'),
  ],
).easySeoHtml(children: [
  SEOSection(
    attributes: {'itemscope': null, 'itemtype': 'https://schema.org/FAQPage'},
    jsonLd: {
      '@type': 'FAQPage',
      'mainEntity': [
        {'@type': 'Question', 'name': 'How does this work?',
         'acceptedAnswer': {'@type': 'Answer', 'text': 'It generates HTML from the widget tree.'}},
        {'@type': 'Question', 'name': 'Is it fast?',
         'acceptedAnswer': {'@type': 'Answer', 'text': 'Yes, it runs asynchronously.'}},
      ],
    },
    children: [
      SEODiv(attributes: {'itemprop': 'mainEntity', 'itemscope': null, 'itemtype': 'https://schema.org/Question'},
        children: [
          SEOH3('How does this work?', attributes: {'itemprop': 'name'}),
          SEODiv(attributes: {'itemprop': 'acceptedAnswer', 'itemscope': null, 'itemtype': 'https://schema.org/Answer'},
            children: [
              SEOParagraph('It generates HTML from the widget tree.', attributes: {'itemprop': 'text'}),
            ]),
        ]),
    ]),
])
```
```html
<section class="faq-page">
  <div class="mainEntity">
    <h3 class="name">How does this work?</h3>
    <div class="acceptedAnswer">
      <p class="text">It generates HTML from the widget tree.</p>
    </div>
  </div>
</section>
<script type="application/ld+json">{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question", 
      "name": "How does this work?", 
      "acceptedAnswer": {
        "@type": "Answer", 
        "text": "It generates HTML from the widget tree."
      }
    },
    {
      "@type": "Question", 
      "name": "Is it fast?", 
      "acceptedAnswer": {
        "@type": "Answer", 
        "text": "Yes, it runs asynchronously."
      }
    }
  ]
}</script>
```

## Examples of HTML + JSON-LD output using wrappers and extensions methods
<div style="display: flex; gap: 20px;">
  <div style="flex: 1;">

### Widget Wrapper
```dart
// Text() to <p> - default behaviour
EasySEOTextWrapper(child: Text('Hello World')) // or
Text('Hello World').easySeoText() // or
Text('Hello World').easySeoP()

// Text() to <h1> ... <h6>
EasySEOTextWrapper(
   textType: SEOTextType.h1, 
   child: Text('Main Topic')
) 
// or
Text('Sub Topic').easySeoText(textType: SEOTextType.h3) 
// or
Text('Least important Topic').easySeoH6()

// any widget to <p>, <h1> ... <h6>
FancyVisualHeader().easySeoH1(text: "Main Topic")
```
---
```dart
Image.network(
  'https://picsum.photos/seed/home/800/400',
   // other params,
).easySeo(alt: 'Image Description')
```
---
```dart
ComplexAnimatedHeaderWidget().easySeoHeader(
 h1: "App Web Version",
 children: [
   SEOAnchor(href: "https://...", content: "AppStore"),
   SEOAnchor(href: "https://...", content: "PlayStore"),
 ]
);
```

---
Navigation Menu
```dart
NavigationRail( // or BottomNavigationBar(...
  ...
  destinations: [
    NavigationRailDestination(
      ...
      label: Text("Item 1").easySeoNavAnchor(
        path: 'https://.../item1')
    ),
    NavigationRailDestination(
      ...
      label: Text("Item 2").easySeoNavAnchor(
        path: 'https://.../item2')
    ),
  ],
).easySeo(globalName: "main_navigation")

// or

Column(
  children: [
    TextButton(
      onPressed: () => { /* load page 1 */},
      child: Text("Item 1").easySeoNavAnchor(
        path: 'https://.../item1'
      ),
    ),
    TextButton(
      onPressed: () { /* load page 2 */ },
      child: Text("Item 2").easySeoNavAnchor(
        path: 'https://.../item2'
      ),
    )
  ]
).easySeoNav(globalName: "main_navigation");


```

---
Breadcrumb Navigation
```dart
Row(
  children: [
    TextButton(
      onPressed: () => { /* load page 1 */},
      child: Text("Products").easySeoNavAnchor(
        path: 'https://.../products'
      ),
    ),
    TextButton(
      onPressed: () { /* load page 2 */ },
      child: Text("Groceries").easySeoNavAnchor(
        path: 'https://.../groceries'
      ),
    )
  ]
).easySeoNav(
  globalName: "breadcrumb_navigation", 
  isBreadcrumb: true
);












```

---
SEO for a product (name, brand, offers ...)
```dart
// var product = ...
// var prices = ...
// var validFrom = ...
// var validTo = ...
ProductCardWidget().easySeoProduct(
  product.name, 
  headingBuilder: SEOH3.new, 
  children: [
    SEOBrand(product.brand.name),
    SEOSizeUnit("${product.size}", product.unit),
    SEOProductOffers(
      lowPrice: prices.first.price,
      highPrice: prices.last.price,
      offerCount: prices.length,
      individualOffers: prices.map((e) => {
        'price': e.price, 
        'seller': e.shop.name, 
        'availability': e.isAvailable}
      ).toList(),
      validFrom: validFrom,
      validThrough: validTo
    )
  ]
)





































































```
  </div>
  <div style="flex: 1;">
    
### HTML Output
```html

<p>Hello World</p>




<h1>Main Topic</h1>




<h3>Sub Topic</h3>

<h6>Least important Topic</h6>


<h1>Main Topic</h1>
```
---
```html
<img src="https://picsum.photos/seed/home/800/400" alt="Image Description"/>


```
---
```html
<header>
  <h1>App Web Version</h1>
  <a href="https://...">AppStore</a>
  <a href="https://...">PlayStore</a>
</header>


```

---
HTML + JSON-LD
```html
<nav>
  <ul>
    <li>
      <a href="https://.../item1">Item 1</a>
    </li>
    <li>
      <a href="https://.../item2">Item 2</a>
    </li>
  </ul>
</nav>
<script type="application/ld+json"> {
  "@context": "https://schema.org",
  "@type": "ItemList",
  "numberOfItems": 2,
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "item": {
        "@type": "SiteNavigationElement",
        "name": "Item 1",
        "url": "https://.../item1"
      }
    }, 
    {
      "@type": "ListItem",
      "position": 2,
      "item": {
        "@type": "SiteNavigationElement",
        "name": "Item 2",
        "url": "https://.../item2"
      }
    }
  ]
}
</script>
```
---
HTML + JOSON-LD
```html
<nav aria-label="Breadcrumb">
  <ol style="display: flex; list-style: none; padding: 0;">
    <li>
      <a href="https://.../products">Products</a>
    </li>
    <span aria-hidden="true" style="margin: 0 8px;">›</span>
    <li>
      <a href="https://.../products/groceries" aria-current="page">Groceries</a>
    </li>
  </ol>
</nav>
<script type="application/ld+json">{
  "@context":"https://schema.org",
  "@type":"BreadcrumbList",
  "itemListElement":[
    {
      "@type":"ListItem",
      "position":1,
      "name":"Products",
      "item":"https://.../products"
    },
    {
      "@type":"ListItem",
      "position":2,"name":
      "Groceries",
      "item":"https://.../products/groceries"
    }
  ]
}
</script>
```

---
HTML + JSON-LD
```html
<article>
  <h3 class="name">Water</h3>
  <img src="https://water.webp" alt="Water, 500 ml" class="image" />
  <p class="brand">
    <span class="name">Water Brand</span>
  </p>
  <p class="additionalProperty">
    <span class="name">weight</span>
    <span class="value">500</span>
    <span class="unitText">ml</span>
  </p>
  <div class="aggregateOffer">
    <span class="lowPrice">1.48</span>
    <span class="highPrice">1.68</span>
    <span class="offerCount">2</span>
    <span class="priceCurrency">EUR</span>
    <ul class="offers-list">
      <li class="offer-item">
        <span class="price">1.48</span>
        <span class="priceCurrency">EUR</span>
        <div class="seller">
          <span class="name">Shop 1</span>
        </div>
        <time class="validThrough" datetime="2026-06-17T00:00:00.000Z">17.06.2026</time>
        <time class="validFrom" datetime="2026-06-11T00:00:00.000Z">11.06.2026</time>
      </li>
      <li class="offer-item">
        <span class="price">1.68</span>
        <span class="priceCurrency">EUR</span>
        <div class="seller">
          <span class="name">Shop 2</span>
        </div>
        <time class="validThrough" datetime="2026-06-17T00:00:00.000Z">17.06.2026</time>
        <time class="validFrom" datetime="2026-06-11T00:00:00.000Z">11.06.2026</time>
      </li>
    </ul>
  </div>
</article>
<script type = "application/ld+json"> {
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Water",
  "image": ["https://water.webp"],
  "brand": {
    "@type": "Brand",
    "name": "Water Brand"
  },
  "additionalProperty": [{
      "@type": "PropertyValue",
      "name": "weight",
      "value": "500",
      "unitText": "ml"
    }
  ],
  "offers": {
    "@type": "AggregateOffer",
    "lowPrice": 1.48,
    "highPrice": 1.68,
    "offerCount": 2,
    "priceCurrency": "EUR",
    "offers": [{
        "@type": "Offer",
        "price": 1.48,
        "priceCurrency": "EUR",
        "itemCondition": "https://schema.org/NewCondition",
        "availability": "https://schema.org/InStock",
        "seller": {
          "@type": "Organization",
          "name": "Shop 1"
        },
        "validThrough": "2026-06-17T00:00:00.000Z",
        "validFrom": "2026-06-11T00:00:00.000Z"
      }, {
        "@type": "Offer",
        "price": 1.68,
        "priceCurrency": "EUR",
        "itemCondition": "https://schema.org/NewCondition",
        "availability": "https://schema.org/InStock",
        "seller": {
          "@type": "Organization",
          "name": "Shop 2"
        },
        "validThrough": "2026-06-17T00:00:00.000Z",
        "validFrom": "2026-06-11T00:00:00.000Z"
      }
    ]
  }
}
</script>
```
  </div>
</div>

## API Reference

### Text wrappers

| Method / Class | HTML Tag | JSON-LD | Notes |
|---|---|---|---|
| `EasySEOTextWrapper` / `.easySeoText()` | `p` (default) or `h1`–`h6` | — | `textType:` controls heading level |
| `.easySeoP()` / `.easySeoH1()`–`.easySeoH6()` | `p` / `h1`–`h6` | — | Convenience shorthands for `easySeoText` |
| `"string".easySeoP` / `.easySeoH1`–`.easySeoH6` | `<p>string</p>` / `<h1>string</h1>`–`<h6>string</h6>` | — | String extension getters |
| `"string".easySeoBrand` | `<p itemprop="brand"></p>` | `{"@type": "Brand", "name": "…"}` | Empty `<p>` — brand name in JSON-LD only |
| `SEOBrand(name)` | `<p itemprop="brand"></p>` | `{"@type": "Brand", "name": "…"}` | Same as above, tag-class form |
| `SEOParagraph(content)` | `<p>content</p>` | — | Tag class for `<p>` |
| `SEOH1(content)`–`SEOH6(content)` | `<h1>content</h1>`–`<h6>content</h6>` | — | Tag classes for headings |

### Structural / Semantic wrappers

| Method / Class | HTML Tag | JSON-LD | Notes |
|---|---|---|---|
| `EasySEOHeaderWrapper` / `.easySeoHeader()` | `<header>…</header>` | — | Optional `h1:` / `p:` params insert `<h1>`/`<p>` as first children |
| `EasySEOSectionWrapper` / `.easySeoSection()` | `<section>…</section>` | — | — |
| `EasySEOArticleWrapper` / `.easySeoArticle()` | `<article>…</article>` | via `jsonLd:` param | — |
| `EasySEOMainWrapper` / `.easySeoMain()` | `<main>…</main>` | — | — |
| `EasySEOFooterWrapper` / `.easySeoFooter()` | `<footer>…</footer>` | — | Sorts last among siblings |
| `EasySEOAsideWrapper` / `.easySeoAside()` | `<aside>…</aside>` | — | — |
| `EasySEOFigureWrapper` / `.easySeoFigure()` | `<figure>…</figure>` | — | Optional `caption:` appends `<figcaption>` |
| `EasySEOFormWrapper` / `.easySeoForm()` | `<form>…</form>` | — | — |
| `EasySEOContainerWrapper` / `.easySeoContainer()` | `div` (configurable via `tag:`) | — | Allows arbitrary tag name |
| `EasySEOCustomWrapper` / `.easySeo()` | configurable `tag:` (default `div`) | — | Also accepts `builder:` for custom rendering |
| `.easySeoHtml()` | *(raw children, no wrapper tag)* | — | Injects children as-is into the HTML body |

### Links & Navigation

| Method / Class | HTML Tag | JSON-LD | Notes |
|---|---|---|---|
| `EasySEOLinkWrapper` / `.easySeoAnchor(path:)` | `<a href="…">text</a>` | — | `path:` resolved via `formatFullUrl`; `text:` optional (auto-extracted from child) |
| `EasySEONavLinkWrapper` / `.easySeoNavAnchor(path:)` | `<li><a href="…">text</a></li>` | — | Wraps anchor in `<li>` |
| `EasySEONavWrapper` / `.easySeoNav()` | `<nav><ul><li><a>…</a></li>…</ul></nav>` | `ItemList` / `SiteNavigationElement` | Auto-collects nav items from `easySeoNavAnchor` children |
| `EasySEONavWrapper` / `.easySeoNav(isBreadcrumb: true)` | `<nav aria-label="Breadcrumb"><ol><li>…<span>›</span></li>…</ol></nav>` | `BreadcrumbList` | Last link gets `aria-current="page"` |
| `SEOAnchor(href: / path:)` | `<a href="…">content</a>` | — | Tag class; `path:` resolved, `href:` used verbatim |
| `SEOListItem(…)` | `<li>…</li>` | — | Tag class |
| `SEOUnorderedList(…)` | `<ul>…</ul>` | — | Tag class |
| `SEOOrderedList(…)` | `<ol>…</ol>` | — | Tag class |
| `SEONav(…)` | `<nav>…</nav>` | — | Tag class |

### Media & Time

| Method / Class | HTML Tag | JSON-LD | Notes |
|---|---|---|---|
| `EasySEOImageWrapper` / `.easySeoImage()` | `<img src="…" alt="…" />` | — | `src:` auto-extracted from child `NetworkImage` |
| `EasySEOTimeWrapper` / `.easySeoTime(dateTime:)` | `<time datetime="2026-01-01T00:00:00.000">text</time>` | — | `dateTime:` required, `text:` optional |
| `SEOImage(attributes:)` | `<img … />` | — | Tag class |
| `SEOTime(dateTime:, text:)` | `<time datetime="…">text</time>` | — | Tag class |

### Product / Schema helpers

| Method / Class | HTML Tag | JSON-LD | Notes |
|---|---|---|---|
| `.easySeoProduct(name)` / `EasySEOArticleWrapper` | `<article itemscope itemtype="https://schema.org/Product">…</article>` | `{"@type": "Product", "name": "…"}` | `headingBuilder:` defaults to `SEOH1.new`; optional `path:` for URL itemprop |
| `SEOBrand(name)` | `<p itemprop="brand"></p>` | `{"@type": "Brand", "name": "…"}` | — |
| `SEOSizeUnit(size, unit)` | `<p itemprop="additionalProperty"></p>` | `{"@type": "PropertyValue", "name": "weight", "value": "…", "unitText": "…"}` | — |
| `SEOProductOffers(lowPrice:, highPrice:, offerCount:, …)` | `<div itemprop="offers" class="aggregateOffer"></div>` | `{"@type": "AggregateOffer", "lowPrice": …, "highPrice": …, "offerCount": …, "offers": […]}` | Each offer in `individualOffers:` becomes an `{"@type": "Offer", …}` with seller, availability, validThrough/validFrom |

### SEOHtml tag classes

Each class extends `SEOHtml` and is usable anywhere a `List<SEOHtml>` is expected (e.g. the `children:` param on any wrapper or extension).

| Class | HTML Tag | Content param | Special |
|---|---|---|---|
| `SEOH1`–`SEOH6` | `h1`–`h6` | positional `String` | — |
| `SEOParagraph` | `p` | positional `String` | — |
| `SEODiv` | `div` | named `content` | — |
| `SEOSpan` | `span` | positional `String` | — |
| `SEOSection`, `SEOArticle`, `SEOAside` | `section`, `article`, `aside` | named `content` | — |
| `SEOHeader` | `header` | named `content` | Also accepts `h1:` / `p:` (prepended before children) |
| `SEOMain`, `SEOFooter`, `SEONav` | `main`, `footer`, `nav` | named `content` | — |
| `SEOFigure`, `SEOFigcaption` | `figure`, `figcaption` | named `content` | — |
| `SEOTime` | `time` | named `text` | Requires `dateTime:` — adds `datetime` attribute |
| `SEOUnorderedList`, `SEOOrderedList` | `ul`, `ol` | named `content` | — |
| `SEOListItem` | `li` | named `content` | — |
| `SEOAnchor` | `a` | named `content` | Accepts `href:` / `path:` / `relativePath:` — resolves URLs |
| `SEOImage` | `img` | *(self-closing)* | Only `attributes:` |
| `SEOScript` | `script` | named `content` | — |
| `SEOMeta` | `meta` | *(self-closing)* | Only `attributes:` |
| `SEOLink` | `link` | *(self-closing)* | Only `attributes:` |

### Head tag sources

| Class | Produces | Added to |
|---|---|---|
| `EasySEOOgTags(title:, description:, imageUrl:, url:, type:, siteName:)` | Multiple `<meta property="og:…">` tags | `EasySEOPage.headTags` / `EasySEOManager.headTags` |
| `EasySEOTwitterTags(card:, site:, title:, description:, image:)` | Multiple `<meta name="twitter:…">` tags | Same |
| `EasySEOAppleHeadTags(title:, iconUrl:, statusBarStyle:, isWebAppCapable:)` | Apple PWA `<meta>` and `<link>` tags | Same |
| `SEOServiceInfo(serviceType:, providerName:, brandLogoUrl:, areasServed:)` | `<script type="application/ld+json">` with `Service` schema | Same |

All head tag sources implement `EasySEOHeadTagSource` and are flattened via `toHeadTags()`.

## License

MIT License
