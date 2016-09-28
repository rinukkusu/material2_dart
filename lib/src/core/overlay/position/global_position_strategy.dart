import "dart:html";
import "dart:async";
import "../../style/apply_transform.dart";
import "position_strategy.dart";

/// A strategy for positioning overlays. Using this strategy, an overlay is given an
/// explicit position relative to the browser's viewport.
///
/// FIXME: May change API such as [fixed()] not to return `this` to follow CQS principle.
class GlobalPositionStrategy implements PositionStrategy {
  String _cssPosition = "absolute";
  String _top = "";
  String _bottom = "";
  String _left = "";
  String _right = "";

  /// Array of individual applications of translateX(). Currently only for centering.
  List<String> _translateX = [];

  /// Array of individual applications of translateY(). Currently only for centering.
  List<String> _translateY = [];

  /// Sets the element to use CSS position: fixed.
  GlobalPositionStrategy fixed() {
    _cssPosition = "fixed";
    return this;
  }

  /// Sets the element to use CSS position: absolute. This is the default.
  GlobalPositionStrategy absolute() {
    _cssPosition = "absolute";
    return this;
  }

  /// Sets the top position of the overlay. Clears any previously set vertical position.
  GlobalPositionStrategy top(String value) {
    _bottom = "";
    _translateY = [];
    _top = value;
    return this;
  }

  /// Sets the left position of the overlay. Clears any previously set horizontal position.
  GlobalPositionStrategy left(String value) {
    _right = "";
    _translateX = [];
    _left = value;
    return this;
  }

  /// Sets the bottom position of the overlay. Clears any previously set vertical position.
  GlobalPositionStrategy bottom(String value) {
    _top = "";
    _translateY = [];
    _bottom = value;
    return this;
  }

  /// Sets the right position of the overlay. Clears any previously set horizontal position.
  GlobalPositionStrategy right(String value) {
    _left = "";
    _translateX = [];
    _right = value;
    return this;
  }

  /// Centers the overlay horizontally with an optional offset.
  /// Clears any previously set horizontal position.
  GlobalPositionStrategy centerHorizontally([String offset = "0px"]) {
    _left = "50%";
    _right = "";
    _translateX = ["-50%", offset];
    return this;
  }

  /// Centers the overlay vertically with an optional offset.
  /// Clears any previously set vertical position.
  GlobalPositionStrategy centerVertically([String offset = "0px"]) {
    _top = "50%";
    _bottom = "";
    _translateY = ["-50%", offset];
    return this;
  }

  /// Apply the position to the element.
  @override
  Future apply(Element element) {
    element.style
      ..position = _cssPosition
      ..top = _top
      ..left = _left
      ..bottom = _bottom
      ..right = _right;
    // TODO(jelbourn): we don't want to always overwrite the transform property here,

    // because it will need to be used for animations.
    String tranlateX = _reduceTranslateValues("translateX", _translateX);
    String translateY = _reduceTranslateValues("translateY", _translateY);
    applyCssTransform(element, '$tranlateX $translateY');
    return new Future<Null>.value();
  }

  // Reduce a list of translate values to a string that can be used in the transform property.
  String _reduceTranslateValues(String translateFn, List<String> values) {
    return values.map((String t) => '$translateFn($t)').join(' ');
  }
}
