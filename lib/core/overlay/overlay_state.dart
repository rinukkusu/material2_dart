import "position/position_strategy.dart";

/// OverlayState is a bag of values for either the initial configuration
/// or current state of an overlay.
class OverlayState {
  /// Strategy with which to position the overlay.
  PositionStrategy positionStrategy;

  /// Whether the overlay has a backdrop.
  bool hasBackdrop = false;
}
