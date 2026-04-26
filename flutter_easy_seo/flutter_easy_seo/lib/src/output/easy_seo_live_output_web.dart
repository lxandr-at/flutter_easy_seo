import 'dart:js_interop';
import 'easy_seo_live_output_base.dart';
import 'package:web/web.dart' as web;

class EasySEOLiveOutput with EasySEOLiveOutputBase {
  @override
  void injectToHead(String htmlContent) {
    final head = web.document.head;
    if (head != null) {
      // We create this in memory, NOT in the live document
      final tempElement = web.document.createElement('div');
      // The browser parses the string and creates the nodes inside the div
      tempElement.innerHTML = htmlContent.toJS;
      // Now we move the CHILDREN of the div into the head
      while (tempElement.firstChild != null) {
        head.appendChild(tempElement.firstChild!);
      }
    }
  }

  @override
  void injectToBody(String htmlContent) {
    final body = web.document.body;
    if (body == null) return;

    // 1. Check if we already injected something and remove it (Cleanup)
    final existing = web.document.getElementById('easy-seo-root');
    existing?.remove();

    // 2. Create the wrapper
    // We use <section> for semantic value
    final wrapper = web.document.createElement('section') as web.HTMLElement;

    // 3. Identification
    wrapper.id = 'easy-seo-root';
    // Custom data attributes are great for internal package logic
    wrapper.setAttribute('data-generated-by', 'flutter_easy_seo');

    // Apply "Visually Hidden" (Screen Reader Only) Styles
    // This keeps the content in the Accessibility Tree but hides it visually
    final style = wrapper.style;
    style.position = 'absolute';
    style.width = '1px';
    style.height = '1px';
    style.padding = '0';
    style.margin = '-1px';
    style.overflow = 'hidden';
    style.clip = 'rect(0, 0, 0, 0)';
    style.whiteSpace = 'nowrap';
    style.border = '0';
    // Ensure it doesn't accidentally interfere with Flutter's pointer events
    style.pointerEvents = 'none';

    wrapper.innerHTML = htmlContent.toJS;

    // 5. Inject at the top of the body
    body.insertBefore(wrapper, body.firstChild);
  }
}