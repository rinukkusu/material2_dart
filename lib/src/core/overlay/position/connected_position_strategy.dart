import 'dart:html';
import "dart:async";
import "position_strategy.dart";
import "package:angular2/core.dart";
import "viewport_ruler.dart";
import "../..//style/apply_transform.dart";
import "connected_position.dart";

/**
 * A strategy for positioning overlays. Using this strategy, an overlay is given an
 * implict position relative some origin element. The relative position is defined in terms of
 * a point on the origin element that is connected to a point on the overlay element. For example,
 * a basic dropdown is connecting the bottom-left corner of the origin to the top-left corner
 * of the overlay.
 */
class ConnectedPositionStrategy implements PositionStrategy {
  ElementRef connectedTo;
  OriginConnectionPosition _originPos;
  OverlayConnectionPosition _overlayPos;
  ViewportRuler _viewportRuler;

  // TODO(jelbourn): set RTL to the actual value from the app.

  /** Whether the we're dealing with an RTL context */
  bool _isRtl = false;

  /** Ordered list of preferred positions, from most to least desirable. */
  List<ConnectionPositionPair> _preferredPositions = [];

  /** The origin element against which the overlay will be positioned. */
  Element _origin;

  ConnectedPositionStrategy(ElementRef _connectedTo, this._originPos,
      this._overlayPos, this._viewportRuler)
      : this.connectedTo = _connectedTo,
        _origin = _connectedTo.nativeElement as Element {
    withFallbackPosition(_originPos, _overlayPos);
  }

  List<ConnectionPositionPair> get positions => _preferredPositions;

  /**
   * Updates the position of the overlay element, using whichever preferred position relative
   * to the origin fits on-screen.
   */
  @override
  Future apply(Element element) {
    // We need the bounding rects for the origin and the overlay to determine how to position
    // the overlay relative to the origin.
    final originRect = _origin.getBoundingClientRect();
    final overlayRect = element.getBoundingClientRect();
    // We use the viewport rect to determine whether a position would go off-screen.
    final viewportRect = _viewportRuler.getViewportRect();
    Point firstOverlayPoint;
    // We want to place the overlay in the first of the preferred positions such that the
    // overlay fits on-screen.
    for (var pos in _preferredPositions) {
      // Get the (x, y) point of connection on the origin, and then use that to get the
      // (top, left) coordinate for the overlay at `pos`.
      var originPoint = _getOriginConnectionPoint(originRect, pos);
      var overlayPoint = _getOverlayPoint(originPoint, overlayRect, pos);
      firstOverlayPoint = firstOverlayPoint ?? overlayPoint;
      // If the overlay in the calculated position fits on-screen, put it there and we're done.
      if (_willOverlayFitWithinViewport(
          overlayPoint, overlayRect, viewportRect)) {
        this._setElementPosition(element, overlayPoint);
        return new Future<Null>.value();
      }
    }
    // TODO(jelbourn): fallback behavior for when none of the preferred positions fit on-screen.
    // For now, just stick it in the first position and let it go off-screen.
    _setElementPosition(element, firstOverlayPoint);
    return new Future<Null>.value();
  }

  ConnectedPositionStrategy withFallbackPosition(OriginConnectionPosition originPos,
      OverlayConnectionPosition overlayPos) {
    _preferredPositions.add(new ConnectionPositionPair(originPos, overlayPos));
    return this;
  }

  /**
   * Gets the horizontal (x) "start" dimension based on whether the overlay is in an RTL context.
   */
  num _getStartX(Rectangle rectangle) =>
      _isRtl ? rectangle.right : rectangle.left;

  /**
   * Gets the horizontal (x) "end" dimension based on whether the overlay is in an RTL context.
   */
  num _getEndX(Rectangle rectangle) =>
      _isRtl ? rectangle.left : rectangle.right;

  /**
   * Gets the (x, y) coordinate of a connection point on the origin based on a relative position.
   */
  Point _getOriginConnectionPoint(
      Rectangle originRectangle, ConnectionPositionPair positionPair) {
    final originStartX = _getStartX(originRectangle);
    final originEndX = _getEndX(originRectangle);
    num x;
    if (positionPair.originX == HorizontalConnectionPos.center) {
      x = originStartX + (originRectangle.width / 2);
    } else {
      x = positionPair.originX == HorizontalConnectionPos.start
          ? originStartX
          : originEndX;
    }
    num y;
    if (positionPair.originY == VerticalConnectionPos.center) {
      y = originRectangle.top + (originRectangle.height / 2);
    } else {
      y = positionPair.originY == VerticalConnectionPos.top
          ? originRectangle.top
          : originRectangle.bottom;
    }
    return new Point(x, y);
  }

  /**
   * Gets the (x, y) coordinate of the top-left corner of the overlay given a given position and
   * origin point to which the overlay should be connected.
   */
  Point _getOverlayPoint(Point originPoint, Rectangle overlayRectangle,
      ConnectionPositionPair positionPair) {
    // Calculate the (overlayStartX, overlayStartY), the start of the potential overlay position
    // relative to the origin point.
    num overlayStartX;
    if (positionPair.overlayX == HorizontalConnectionPos.center) {
      overlayStartX = -overlayRectangle.width / 2;
    } else {
      overlayStartX = positionPair.overlayX == HorizontalConnectionPos.start
          ? 0
          : -overlayRectangle.width;
    }
    num overlayStartY;
    if (positionPair.overlayY == VerticalConnectionPos.center) {
      overlayStartY = -overlayRectangle.height / 2;
    } else {
      overlayStartY = positionPair.overlayY == VerticalConnectionPos.top
          ? 0
          : -overlayRectangle.height;
    }
    return new Point(
        originPoint.x + overlayStartX, originPoint.y + overlayStartY);
  }

  /**
   * Gets whether the overlay positioned at the given point will fit on-screen.
   * @param overlayPoint The top-left coordinate of the overlay.
   * @param overlayRect Bounding rect of the overlay, used to get its size.
   * @param viewportRect The bounding viewport.*
   */
  bool _willOverlayFitWithinViewport(
      Point overlayPoint, Rectangle overlayRect, Rectangle viewportRect) {
    // TODO(jelbourn): probably also want some space between overlay edge and viewport edge.
    return overlayPoint.x >= viewportRect.left &&
        overlayPoint.x + overlayRect.width <= viewportRect.right &&
        overlayPoint.y >= viewportRect.top &&
        overlayPoint.y + overlayRect.height <= viewportRect.bottom;
  }

  /**
   * Physically positions the overlay element to the given coordinate.
   */
  void _setElementPosition(Element element, Point overlayPoint) {
    var scrollPos = _viewportRuler.getViewportScrollPosition();
    var x = overlayPoint.x + scrollPos['left'];
    var y = overlayPoint.y + scrollPos['top'];
    // TODO(jelbourn): we don't want to always overwrite the transform property here,
    // because it will need to be used for animations.
    applyCssTransform(element, 'translateX(${x}px) translateY(${y}px)');
  }
}
