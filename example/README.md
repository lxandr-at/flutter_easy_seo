# flutter_easy_seo Example — Hotel Reservation Demo

A multi-page hotel booking web app that demonstrates every major feature of the `flutter_easy_seo` package — from semantic widget wrappers and JSON-LD structured data to a fully automated SEO generation pipeline.

**Live Demo:** https://fluttereasyseo.lxandr.at/example/en

---

## Quick Start

```bash
cd example
flutter pub get
```

**Run with Interactive Mode** (preview HTML, highlights, download):
```bash
flutter run -d chrome
```

**Run the automated SEO generation pipeline** (headless, writes snapshot files):
```bash
flutter test test/seo_generation_test.dart
```

The test writes snapshot files to `web/seo_snapshots/` and `web/sitemap.xml` by default (`sendToRestApi = false`, line 12). Set it to `true` to upload generated HTML to a REST endpoint instead.

---

## Switching Between Router Implementations

The example implements four routing engines behind a shared `RouterAdapter` abstraction:

| Router | File | Status |
|---|---|---|
| GoRouter | `lib/routing/router_go.dart` | **Active (default)** |
| Vanilla Navigator 1.0 | `lib/routing/router_vanilla.dart` | Available |
| Beamer | `lib/routing/router_beamer.dart` | Available |
| auto_route | `lib/routing/router_autoroute.dart` | Available |

To switch, edit `lib/routing/app_router.dart` — uncomment the desired export and comment out the others:

```dart
export 'router_go.dart';          // GoRouter (default)
// export 'router_vanilla.dart';   // Vanilla Navigator 1.0
// export 'router_beamer.dart';    // Beamer
// export 'router_autoroute.dart'; // auto_route (requires: dart run build_runner build)
```

All four produce identical SEO output. The abstraction layer (`lib/routing/nav_adapter.dart`) defines `buildApp`, `push`, `go`, `pop`, `getCurrentPath`, `getPathSegments`, `getLocale`, and `replaceLocale` so every page and widget is router-agnostic.

---

## Architecture Overview

```
RouterAdapter
 ├── GoRouter (default)
 ├── Vanilla Navigator 1.0
 ├── Beamer
 └── auto_route

ShellLayout           ← header, nav, footer (shared across pages)
 ├── LandingPage      ← hero, features, FAQ
 ├── HotelListPage     ← list of 6 hotel cards
 ├── HotelDetailPage   ← rendered as dialog overlay, full SEO page
 └── ReservationsPage  ← reservation list

State (Riverpod)
 ├── hotelsProvider         — AsyncNotifierProvider (50ms simulated delay)
 ├── breadcrumbProvider     — NotifierProvider (push/pop/clear)
 └── reservationsProvider   — NotifierProvider (static sample data)
```

### Shell Layout & Global Includes

`ShellLayout` (`lib/widgets/shell_layout.dart`) composes the `AppHeader`, `AppNavigation`, and `AppFooter` around each page's content. These shell widgets are registered with `globalName`:

- `app-header` — `AppHeader`
- `app-nav` — `AppNavigation`
- `navigation_breadcrumb` — `Breadcrumb`
- `app-footer` — `AppFooter`

Each `EasySEOPage` references them via `includeGlobals: ['app-header', 'app-nav', 'navigation_breadcrumb', 'app-footer']`, merging these out-of-tree widgets into the generated HTML automatically.

---

## SEO Features Walkthrough

### 1. EasySEOManager Configuration

The singleton is initialized inside each router adapter's `buildApp()` method (`lib/routing/router_go.dart:82-95`):

```dart
EasySEOManager.instance.init(
  baseUrl: 'https://fluttereasyseo.lxandr.at/example',
  supportedLanguages: ['de', 'en', 'fr'],
  pages: ['/', '/hotels', '/hotels/:hotelId'],
  enableInteractiveMode: true,
  showHighlights: true,
  disableOnGenerate: true,
  enableLiveOutput: true,
  pathProvider: (context) =>
      GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration.uri.toString(),
  headTags: [
    const SEOServiceInfo(
      serviceType: 'Hotel Reservation',
      providerName: 'Hotel Buchungsplattform',
      brandLogoUrl: '/logo.png',
      areasServed: ['DE', 'AT', 'CH', 'FR'],
    ),
  ],
);
```

| Parameter | Purpose |
|---|---|
| `baseUrl` | Absolute canonical/alternate links |
| `supportedLanguages` | `hreflang` alternates + sitemap locale entries |
| `pages` | Static routes + dynamic pattern (`:hotelId`) for auto-discovery |
| `pathProvider` | Resolves true URL path (required by declarative routers) |
| `headTags` | Global `<head>` tags — injects `SEOServiceInfo` JSON-LD on every page |
| `enableInteractiveMode` | Shows the floating debug overlay in the live app |
| `showHighlights` | Colored borders around SEO-tracked widgets |

### 2. EasySEOPage on Each View

Every page wraps its content with `EasySEOPage`. Here is the pattern, shown from `lib/pages/landing_page.dart`:

```dart
final route = widget.route.isNotEmpty ? widget.route : '/${widget.locale}';
return EasySEOPage(
  key: ValueKey(route),
  title: t['demo.landing.title']!,
  description: t['demo.landing.description'],
  includeGlobals: ['app-header', 'app-nav', 'navigation_breadcrumb', 'app-footer'],
  child: body,
);
```

Pages that load async data also supply `whenDone`:

```dart
// lib/pages/hotel_list_page.dart
whenDone: () async => await ref.read(hotelsProvider.future),
```

The hotel detail page overrides the dialog/list ambiguity with `rank`:

```dart
// lib/pages/hotel_detail_page.dart
return EasySEOPage(
  key: ValueKey(route),
  rank: 1,
  title: '$hotelName ${t['demo.hotelsdetail.title']}',
  description: ...
);
```

### 3. Semantic Widget Wrappers

Each shared widget and page section uses the package's wrapper extensions to produce semantic HTML.

#### Header → `<header>`

`lib/widgets/app_header.dart` uses `.easySeoHeader()` with an `<h1>` and a `<p>`:

```dart
Container(...).easySeoHeader(
  h1: title,
  p: t['landing.hero.subtitle'],
  globalName: 'app-header',
);
```

#### Footer → `<footer>`

`lib/widgets/app_footer.dart` uses `.easySeoFooter()`:

```dart
Container(...).easySeoFooter(globalName: 'app-footer');
```

#### Navigation → `<nav>` with `<ul>/<li>/<a>` + JSON-LD `ItemList`

`lib/widgets/app_navigation.dart` uses `.easySeo()` with `globalName` and `.easySeoNavAnchor()` on individual `NavigationDestination` items:

```dart
NavigationBar(...).easySeo(globalName: 'app-nav');
```

#### Breadcrumb → `<nav aria-label="Breadcrumb">` + JSON-LD `BreadcrumbList`

`lib/widgets/breadcrumb.dart` uses `.easySeoNav(isBreadcrumb: true, globalName: "navigation_breadcrumb")` around the breadcrumb row:

```dart
Row(children: [
  GestureDetector(...).easySeoNavAnchor(path: '/$locale', text: t['nav.home']!),
  for (var i = 0; i < segments.length; i++) ...[
    Text(' › '),
    GestureDetector(...).easySeoNavAnchor(
      path: '/$locale/${segments.sublist(0, i + 1).map((s) => s.slug).join('/')}',
      text: segments[i].label,
    ),
  ],
]).easySeoNav(isBreadcrumb: true, globalName: "navigation_breadcrumb");
```

#### Main Content → `<main>`, `<section>`, `<article>`, `<aside>`

Landing page sections:

```dart
// lib/pages/landing_page.dart
SingleChildScrollView(...).easySeoMain(children: [
  SEOArticle(jsonLd: {'@type': 'WebPage', 'name': ..., 'description': ...}),
]);

_buildHero(...) → Container(...).easySeoSection(children: [
  SEOH1(t['landing.hero.title']!),
  SEOParagraph(t['landing.hero.subtitle']!),
]);

_buildFeatures(...) → Padding(...).easySeoSection(children: [
  SEOH2(t['landing.features.title']!),
  ...featureTexts.map((f) => SEOArticle(children: [SEOParagraph(f)])),
]);
```

Hotel detail amenities (`lib/pages/hotel_detail_page.dart`):

```dart
Padding(...).easySeoAside(children: [
  SEOH2(t['hotel.benefits']!),
  ...amenities.map((a) => SEOParagraph(a)),
]);
```

#### List → `<ul>`/`<li>` + JSON-LD

`lib/widgets/hotel_card.dart` uses `.easySeoListItem()` on each card:

```dart
Card(...).easySeoListItem(children: [
  SEOH3(hotel.name, attributes: {'itemprop': 'name'}),
  SEOAnchor(path: '/$locale/hotels/${hotel.id}', content: hotel.name),
  SEOSpan(hotel.location),
  SEOSpan(hotel.pricePerNight.toStringAsFixed(0)),
]);
```

The hotel list's `Column` is wrapped with `.easySeoList()` (`lib/pages/hotel_list_page.dart`):

```dart
Column(children: hotels.map((hotel) => HotelCard(...)).toList()).easySeoList(),
```

#### Image → `<img>`

```dart
EasySEOImageWrapper(alt: hotel.name, child: Image.network(...));
```

#### FAQ → `<section>` with JSON-LD `FAQPage`

`lib/widgets/faq_block.dart`:

```dart
Column(...).easySeoFaq(
  items: items.map((e) => EasySEOFaqItem(question: e.question, answer: e.answer)).toList(),
);
```

#### Custom HTML Composition

`lib/widgets/raw_seo_demo.dart` demonstrates composing arbitrary HTML/JSON-LD using the package's core `SEOHtml` subclasses:

```dart
Container(...).easySeoHtml(children: [
  const SEOH3('Raw SEO Composition'),
  const SEOSpan('This text uses SEOSpan directly.'),
  SEOTime(text: 'Published', dateTime: DateTime(2026, 6, 28)),
  const SEOParagraph('Paragraph built from SEOHtml subclasses.'),
  SEODiv(
    children: [
      const SEOSpan('Nested inside SEODiv'),
      SEODiv(jsonLd: {'@type': 'CreativeWork', 'name': 'SEO Demo Example'}),
    ],
  ),
]);
```

### 4. JSON-LD Structured Data

The example generates structured data across every page:

| JSON-LD `@type` | Location | File |
|---|---|---|
| `ServiceInfo` | Global `<head>` (each page) | `router_go.dart:90` |
| `WebPage` | Landing page | `landing_page.dart:62` |
| `Hotel` + `AggregateRating` + `Review` | Hotel detail | `hotel_detail_page.dart:156-195` |
| `FAQPage` | FAQ block | `faq_block.dart` |
| `BreadcrumbList` | Breadcrumb nav | `breadcrumb.dart` |
| `ItemList` / `SiteNavigationElement` | Bottom navigation | `app_navigation.dart` |

### 5. Dialog as SEO Page

The hotel detail page renders as a **modal overlay dialog** rather than a full-screen route. This is achieved in `router_go.dart` using a `Positioned.fill` overlay inside the shell, avoiding GoRouter's `pageBuilder` dialog pattern. The page receives full SEO treatment — `EasySEOPage` with `rank: 1` to disambiguate it from the hotel list page beneath it.

### 6. Locale Support

Three languages (German, English, French) are served under locale-prefixed routes (`/de`, `/en`, `/fr`). Localized strings are defined in `lib/l10n/app_translations.dart` — a simple `Map<String, Map<String, String>>` without a third-party i18n library. The locale dropdown in `AppHeader` navigates via `replaceLocale`.

### 7. Dynamic Route Discovery

The `pages` config includes `'/hotels/:hotelId'` — a dynamic pattern. When the hotel list page generates its HTML, the package parses the output, finds all anchor URLs matching `:hotelId`, and exposes them via `EasySEOManager.instance.getAllRoutes(gatheredOnly: true)`. The automated test then visits each discovered hotel detail route and generates its snapshot.

### 8. Automated SEO Generation Pipeline

File: `lib/../test/seo_generation_test.dart`

The test demonstrates a complete, reusable pipeline for headless SEO generation:

```dart
testSeoWidgets('SEO generation and sitemap', (tester) async {
  // 1. Boot the app
  await tester.pumpWidget(App(initialLocale: 'de'));

  // 2. Simulate browser URL
  setRouteBeforePumpWidget(tester, '/de');

  // 3. Visit static routes
  for (final route in staticRoutes) {
    await visitRouteAndGenerate(route, router, tester);
  }

  // 4. Discover + visit dynamic routes (hotel details)
  var gatheredRoutes = EasySEOManager.instance.getAllRoutes(gatheredOnly: true);
  for (final route in gatheredRoutes) {
    await visitRouteAndGenerate(route, router, tester);
  }

  // 5. Generate sitemap
  await generateAndSendSitemap(tester);
});
```

Key components of the pipeline:

- **`testSeoWidgets`** — wrapper that mocks `path_provider`, `connectivity_plus`, `shared_preferences`, suppresses overflow errors, sets 1920×1080 viewport, and cleans up cache files.
- **`setRouteBeforePumpWidget`** — simulates the browser address bar having a specific URL loaded before the app builds.
- **`waitForRoute`** — yields the `FakeAsync` zone to let real async operations settle, waits for `ValueKey(route)` to appear in the tree, resolves `EasySEOPage.whenDone`, and supports `extraCheck` for custom guards (e.g., localization propagation).
- **`generateActive()`** — calls `EasySEOManager.instance.generateActive()` inside `tester.runAsync()` to allow real I/O.
- **`sendAndWait()`** — when `sendToRestApi = true`, sends the generated HTML to a REST endpoint via `SEOSyncService.sendGeneratedData()`; when `false`, writes to `web/seo_snapshots/<path>/index.html`.
- **`generateAndSendSitemap()`** — calls `EasySEOManager.instance.generateSitemapContent()` and either sends it via `SEOSyncService.sendSitemap()` or writes `web/sitemap.xml` locally, controlled by `sendToRestApi`.
- **`sendToRestApi`** (line 12) — global boolean that switches between REST API delivery and local filesystem snapshots.
- **`SEOSyncService`** (`test/seo_sync_service.dart`) — REST client that sends generated HTML as `multipart/form-data` POSTs to `https://localhost/api/generatedSEOPage` and `https://localhost/api/generatedSitemap`, with `X-API-Key` header and `app_name`/`path` fields. The endpoint parameters (`apiKey`, `apiUrl`, `appName`) are hardcoded as `final` fields (lines 8-10) — edit them directly for your server. The `forceIOClient` parameter enables an `IOClient` with `badCertificateCallback` for local development against self-signed HTTPS endpoints.

Run the test:

```bash
flutter test test/seo_generation_test.dart
```

After completion, the snapshots are either delivered to the configured REST endpoint (`sendToRestApi = true`) or written to `web/seo_snapshots/` and `web/sitemap.xml` (`sendToRestApi = false`).

### 9. Serving to Bots

The `web/.htaccess` file implements the **Dynamic Rendering** delivery pattern:

```
# 1. Detect known search bots by User-Agent
# 2. Verify a pre-rendered snapshot exists
# 3. Serve the snapshot as text/html
RewriteRule ^(.*)$ /seo_snapshots/$1/index.html [L,T=text/html]
```

Human users receive the standard Flutter app; search bots receive the static SEO HTML.

### 10. Production Deployment

#### Subdirectory Deployment

The example is deployed under `/example/` (https://fluttereasyseo.lxandr.at/example/en). Three places must stay in sync with this path:

| Location | Current value | Change if deploying to root |
|---|---|---|
| `web/index.prod.html` | `<base href="/example/">` | `<base href="/">` |
| `EasySEOManager.instance.init` | `baseUrl: 'https://.../example'` | `baseUrl: 'https://yoursite.com'` |
| `web/.htaccess` | `RewriteBase /example/`, paths prefixed `/example/...`, `Service-Worker-Allowed "/example/"` | `RewriteBase /`, remove `/example` from all path patterns |

#### Generic `.htaccess`

The `web/.htaccess` file uses locale-agnostic and page-agnostic patterns that work with any `supportedLanguages` and `pages` configuration without modification:

| `.htaccess` rule | What it matches | Notes |
|---|---|---|
| `RewriteRule ^([a-z]{2}(?:[_\-][a-z]{2})?)?/?$ index.html [L]` (line 79) | Root or any BCP-47 locale code (with optional region suffix) | Handles `de`, `en`, `pt-BR`, `zh_CN`, etc. — no changes needed when adding languages |
| `RewriteRule ^([a-z]{2}(?:[_\-][a-z]{2})?)/(.+)$ index.html [L]` (line 83) | Any locale followed by any page path | Covers all routes (e.g., `/hotels`, `/hotels/2`, `/reservations`) — no new RewriteRules needed for new pages |
| `RewriteCond %{REQUEST_URI} ^/example/(?:[a-z]{2}(?:[_\-][a-z]{2})?/)?(robots\.txt\|sitemap\.xml)` (line 74) | `robots.txt` / `sitemap.xml` at root or under any locale | Ensures crawler-essential files are never hijacked by Flutter routing |
| Bot User-Agent list (line 46) + `bot=1` query param (line 47) | Known crawlers + manual test flag | Review periodically to add new crawler User-Agents |
| `RewriteCond %{REQUEST_FILENAME} -f [OR] -d [OR] -l` (lines 67-69) | Real files, directories, symlinks | Passes through existing assets without hitting Flutter routing |
| Trailing slash normalization (lines 38-40) | Naked `/example` → `/example/` | Only relevant when deploying to a subdirectory |

#### Production Build with the `sw` Package

The `sw` package (`^0.1.5`) replaces Flutter's default bootstrap with an optimized service worker pipeline featuring a professional loading widget, progress tracking, intelligent caching, and CanvasKit CDN loading.

**Install:**

```bash
dart pub global activate sw
```

**Build sequence for production:**

```bash
# 1. Build Flutter web app
flutter build web --release --wasm --base-href=/example/ -o build/web

# 2. Generate service worker + bootstrap
dart run sw:generate \
  --input=build/web \
  --prefix=seo-demo \
  --version="$(git rev-parse --short=8 HEAD)"

# 3. Swap: replace dev index.html with the prod template inside build/web
cp build/web/index.prod.html build/web/index.html
```

This produces `sw.js` and `bootstrap.js` in `build/web/`, removes Flutter's default `flutter_bootstrap.js` / `flutter_service_worker.js`, and injects version placeholders into `index.html`. Deploy the entire `build/web/` directory as-is.

**Server Cache-Control requirements:**

The `sw` package's atomic cache-busting relies on fresh entry files. The `.htaccess` already includes the required headers (lines 11-14):

```apache
<FilesMatch "^(index\.html|bootstrap\.js|sw\.js|version\.json)$">
  Header set Cache-Control "no-cache, no-store, must-revalidate"
</FilesMatch>
```

Static assets (`.wasm`, `.js`, `.png`, etc.) are served with `Cache-Control: public, max-age=31536000, immutable` since the service worker manifest handles invalidation via MD5 hashes.

#### Dev vs Prod Entry Points

| File | `<base href>` | Bootstrap | Used by |
|---|---|---|---|
| `web/index.html` | `/` (dev) | `flutter_bootstrap.js` (Flutter default) | `flutter run` (hot reload) |
| `web/index.prod.html` | `/example/` | `bootstrap.js` (`sw` package) | Production build (step 2 above) |

The `sw` package provides its own `data-sw-bootstrap` script tag with a `data-config` JSON block for theming (logo, title, accent color). The loading widget displays during initialization and auto-disposes on `flutter-first-frame`.

---

## Live Demo

Visit the live demo at https://fluttereasyseo.lxandr.at/example/en to see the Interactive Mode in action — navigate the app, open the SEO overlay (floating button), preview the generated HTML, and toggle highlights to see which widgets are tracked.

| Page | User Version | SEO Version (`?bot=1`) |
|---|---|---|
| Landing | [🌐](https://fluttereasyseo.lxandr.at/example/en) | [🌐](https://fluttereasyseo.lxandr.at/example/en?bot=1) |
| Hotels | [🌐](https://fluttereasyseo.lxandr.at/example/en/hotels) | [🌐](https://fluttereasyseo.lxandr.at/example/en/hotels?bot=1) |
| Hotel Detail | [🌐](https://fluttereasyseo.lxandr.at/example/en/hotels/2) | [🌐](https://fluttereasyseo.lxandr.at/example/en/hotels/2?bot=1) |

---

## Project Structure

```
example/
├── lib/
│   ├── main.dart                     ← Entry point (initial locale: 'de')
│   ├── app.dart                      ← App widget, delegates to RouterAdapter
│   ├── main_simple.dart              ← Minimal standalone demo (Quick Start)
│   ├── l10n/app_translations.dart    ← DE/EN/FR locale strings
│   ├── models/
│   │   ├── hotel.dart                ← Hotel, Review, Reservation data classes
│   │   └── sample_data.dart          ← 6 hotels + 2 reservations
│   ├── pages/
│   │   ├── landing_page.dart         ← EasySEOPage (hero, features, FAQ)
│   │   ├── hotel_list_page.dart      ← EasySEOPage with whenDone
│   │   ├── hotel_detail_page.dart    ← EasySEOPage with rank:1, full Hotel JSON-LD
│   │   └── reservations_page.dart    ← Plain page (no SEO wrappers)
│   ├── providers/
│   │   ├── hotel_provider.dart       ← AsyncNotifierProvider (50ms delay)
│   │   ├── breadcrumb_provider.dart  ← NotifierProvider (push/pop/clear)
│   │   └── reservation_provider.dart ← NotifierProvider
│   ├── routing/
│   │   ├── app_router.dart           ← Router selection (export switch)
│   │   ├── nav_adapter.dart          ← Abstract RouterAdapter + InheritedWidget
│   │   ├── router_go.dart            ← GoRouter implementation (default)
│   │   ├── router_vanilla.dart       ← Navigator 1.0 implementation
│   │   ├── router_beamer.dart        ← Beamer implementation
│   │   ├── router_autoroute.dart     ← auto_route implementation
│   │   ├── dialog_route_helper.dart  ← Shared non-opaque route builder
│   │   └── auto_route/               ← auto_route generated files
│   ├── theme/app_theme.dart          ← Material 3 theme
│   └── widgets/
│       ├── shell_layout.dart         ← Header + content + footer
│       ├── app_header.dart           ← easySeoHeader with locale dropdown
│       ├── app_footer.dart           ← easySeoFooter
│       ├── app_navigation.dart       ← easySeo + easySeoNavAnchor
│       ├── breadcrumb.dart           ← easySeoNav(isBreadcrumb: true)
│       ├── hotel_card.dart           ← EasySEOImageWrapper + easySeoListItem
│       ├── faq_block.dart            ← easySeoFaq
│       ├── review_list.dart          ← Plain review display (no SEO)
│       ├── calendar.dart             ← Date picker (plain)
│       ├── dialog_page.dart          ← Page<dynamic> for dialog routes
│       └── raw_seo_demo.dart         ← easySeoHtml with SEOHtml subclasses
├── test/
│   ├── seo_generation_test.dart      ← Automated SEO generation pipeline
│   └── seo_sync_service.dart         ← REST client for delivering snapshots to server
└── web/
    ├── .htaccess                     ← Bot detection + snapshot serving
    ├── index.html
    ├── robots.txt
    ├── manifest.json
    ├── seo_snapshots/                ← Generated snapshot output
    └── sitemap.xml                   ← Generated sitemap output
```

---

## Key Takeaways

- **`includeGlobals`** is the cleanest way to handle shell-route layouts — header, nav, footer, and breadcrumb are defined once but merged into every page's HTML automatically.
- **Dynamic route discovery** eliminates the need to hardcode high-cardinality URLs (e.g., 1000 hotel detail pages). Declare the pattern once and the package gathers matching URLs from the generated HTML.
- **The `testSeoWidgets` + `waitForRoute` + `generateActive` pipeline** is a production-ready template. Adapt it to your own CI workflow — configure a REST endpoint in `sendAndWait()` to stream snapshots to your server.
- **Dialog overlays can be full SEO pages.** Use `rank` to disambiguate overlapping `EasySEOPage` instances in the widget tree.
- **Four routers, one codebase.** The `RouterAdapter` abstraction proves the package works identically with GoRouter, vanilla Navigator, Beamer, and auto_route.
