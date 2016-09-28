import 'dart:html';
import "dart:async";
import "../portal/portal.dart";
import "overlay_state.dart";

/// Reference to an overlay that has been created with the Overlay service.
/// Used to manipulate or dispose of said overlay.
class OverlayRef implements PortalHost {
  Element _backdropElement;
  ElementStream<MouseEvent> backdropClick;

  PortalHost _portalHost;
  Element _pane;
  OverlayState _state;

  OverlayRef(this._portalHost, this._pane, this._state);

  @override
  Future<dynamic> attach(Portal<dynamic> portal) {
    if (_state.hasBackdrop) {
      _attachBackdrop();
    }

    var attachFuture = _portalHost.attach(portal);
    attachFuture.then/*<dynamic>*/((dynamic _) {
      updatePosition();
    });
    return attachFuture;
  }

  @override
  Future<dynamic> detach() {
    _detachBackdrop();
    return _portalHost.detach();
  }

  @override
  void dispose() {
    _detachBackdrop();
    _portalHost.dispose();
  }

  @override
  bool hasAttached() => _portalHost.hasAttached();

  /// Gets the current state config of the overlay.
  OverlayState getState() => _state;

  /// Updates the position of the overlay based on the position strategy.
  void updatePosition() {
    if (_state.positionStrategy != null) {
      _state.positionStrategy.apply(_pane);
    }
  }

  /// Attaches a backdrop for this overlay.
  void _attachBackdrop() {
    _backdropElement = new DivElement()..classes.add('md-overlay-backdrop');
    _pane.parent.append(_backdropElement);

    // Forward backdrop clicks such that the consumer of the overlay can perform whatever
    // action desired when such a click occurs (usually closing the overlay).
    backdropClick = _backdropElement.onClick;

    // Add class to fade-in the backdrop after one frame.
    window.animationFrame.then/*<num>*/((num _) {
      _backdropElement.classes.add('md-overlay-backdrop-showing');
    });
  }

  /// Detaches the backdrop (if any) associated with the overlay.
  void _detachBackdrop() {
    var backdropToDetach = _backdropElement;

    if (backdropToDetach != null) {
      backdropToDetach.classes.remove('md-overlay-backdrop-showing');
      backdropToDetach.onTransitionEnd.listen((_) {
        backdropToDetach.remove();

        // It is possible that a new portal has been attached to this overlay since we started
        // removing the backdrop. If that is the case, only clear the backdrop reference if it
        // is still the same instance that we started to remove.
        if (_backdropElement == backdropToDetach) {
          _backdropElement = null;
        }
      });
    }
  }
}
