import 'dart:html';
import "package:angular2/core.dart";

/**
 * The ink-bar is used to display and animate the line underneath the current active tab label.
 * @internal
 */
@Directive(selector: "md-ink-bar")
class MdInkBar {
  Renderer _renderer;
  ElementRef _elementRef;

  MdInkBar(this._renderer, this._elementRef) {}

  /**
   * Calculates the styles from the provided element in order to align the ink-bar to that element.
   */
  alignToElement(Element element) {
    _renderer.setElementStyle(
        _elementRef.nativeElement, "left", _getLeftPosition(element));
    _renderer.setElementStyle(
        _elementRef.nativeElement, "width", _getElementWidth(element));
  }

  /**
   * Generates the pixel distance from the left based on the provided element in string format.
   */
  String _getLeftPosition(Element element) {
    return element != null ? element.offsetLeft.toString() + "px" : "0";
  }

  /**
   * Generates the pixel width from the provided element in string format.
   */
  String _getElementWidth(Element element) {
    return element != null ? element.offsetWidth.toString() + "px" : "0";
  }
}
