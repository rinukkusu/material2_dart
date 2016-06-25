import 'dart:html';
import "dart:async";
import "package:angular2/core.dart";
import "position_strategy.dart";

class RelativePositionStrategy implements PositionStrategy {
  ElementRef _relativeTo;

  RelativePositionStrategy(this._relativeTo);

  Future apply(Element element) {
    // Not yet implemented.
    return null;
  }
}
