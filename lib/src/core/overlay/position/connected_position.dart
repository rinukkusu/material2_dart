/** Horizontal dimension of a connection point on the perimeter of the origin or overlay element. */
enum HorizontalConnectionPos { start, center, end }

/** Vertical dimension of a connection point on the perimeter of the origin or overlay element. */
enum VerticalConnectionPos { top, center, bottom }

/** A connection point on the origin element. */
class OriginConnectionPosition {
  HorizontalConnectionPos originX;
  VerticalConnectionPos originY;

  OriginConnectionPosition(this.originX, this.originY);
}

/** A connection point on the overlay element. */
class OverlayConnectionPosition {
  HorizontalConnectionPos overlayX;
  VerticalConnectionPos overlayY;

  OverlayConnectionPosition(this.overlayX, this.overlayY);
}

/** The points of the origin element and the overlay element to connect. */
class ConnectionPositionPair {
  HorizontalConnectionPos originX;
  VerticalConnectionPos originY;
  HorizontalConnectionPos overlayX;
  VerticalConnectionPos overlayY;

  ConnectionPositionPair(
      OriginConnectionPosition origin, OverlayConnectionPosition overlay)
      : originX = origin.originX,
        originY = origin.originY,
        overlayX = overlay.overlayX,
        overlayY = overlay.overlayY;
}

/** The change event emitted by the strategy when a fallback position is used. */
class ConnectedOverlayPositionChange {
  ConnectionPositionPair connectionPair;
  ConnectedOverlayPositionChange(this.connectionPair);
}
