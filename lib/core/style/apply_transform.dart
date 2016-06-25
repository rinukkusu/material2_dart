import 'dart:html';

/**
 * Applies a CSS transform to an element, including browser-prefixed properties.
 */
applyCssTransform(Element element, String transformValue) {
  // It's important to trim the result, because the browser will ignore the set operation
  // if the string contains only whitespace.
  element.style.transform = transformValue.trim();
  // Omitted webkitTransform.
}
