/// Strategy for setting the position on an overlay.
import 'dart:html';
import "dart:async";

abstract class PositionStrategy {
  /// Updates the position of the overlay element.
  Future apply(Element element);
}
