## 1.1.0
- **License:** Relicensed to Apache 2.0.
- **Infrastructure:** Paid turnkey server stacks are now decoupled from the package and managed via Polar.
- Updated Readme.md.
## 1.0.8
- Automatic `llms.txt`/`llms-full.txt` generation for AI crawlers and LLM clients (index + full page Markdown dumps, same route set as the sitemap).
- New `siteName`/`siteDescription` configuration options for the llms.txt header (with automatic root-page fallback).
- Interactive Mode: new "Generate LLMs" button and llms.txt / llms-full.txt download support.
- Changes to example project: Generate `llms.txt`/`llms-full.txt` in seo_generation_test.dart, Link to project, fix breadcrumb bug.
- Updated Readme.md.
## 1.0.7
- Update pub.dev package topics and README metadata
## 1.0.6
- Moved convenience test mocks and utils and sync client to dedicated package flutter_easy_seo_sync.
- Code cleanup.
## 1.0.5
- Moved convenience test mocks and utils to example project. This is a temporary solution to convince pub.dev that this package is suitable for web.
- Removed unused imports and packages.
## 1.0.4
- revert last change
## 1.0.3
- moved test utils to sub package
## 1.0.2
- specify platforms
- fix some warnings
## 1.0.1
- refactor to make some public elements private
- code doc comments
## 1.0.0
- Complete SEO-friendly HTML documents from the live widget tree
- Automatic `sitemap.xml` generation
- SEO-relevant `<head>` tags and metadata (Twitter, Open Graph, custom meta tags)
- **Interactive Mode** with UI overlay for debugging and manual generation
- **Automated Mode** via Flutter Widget Tester for CI and scheduled generation
- JSON-LD structured data and Microdata support
