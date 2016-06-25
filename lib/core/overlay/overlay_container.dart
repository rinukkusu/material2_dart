import 'dart:html';

/**
 * Create the overlay container element, which is simply a div
 * with the 'md-overlay-container' class on the document body.
 */
Element createOverlayContainer() {
  DivElement container = new DivElement()..classes.add("md-overlay-container");
  document.body.append(container);
  return container;
}
