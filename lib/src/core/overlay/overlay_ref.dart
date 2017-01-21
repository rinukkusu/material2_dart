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
  Future<dynamic> attach(Portal<dynamic> portal) async {
    if (_state.hasBackdrop) _attachBackdrop();

    dynamic attachResult = await _portalHost.attach(portal);
    updateSize();
    _updateDirection();
    updatePosition();
    return attachResult;
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

  /// Updates the text direction of the overlay panel.
  void _updateDirection() {
    _pane.attributes['dir'] = _state.direction;
  }

  /// Updates the size of the overlay based on the overlay config.
  void updateSize() {
    if (_state.width != null) {
      _pane.style.width = formatCssUnit(_state.width);
    }

    if (_state.height != null) {
      _pane.style.height = formatCssUnit(_state.height);
    }
  }

  /// Attaches a backdrop for this overlay.
  void _attachBackdrop() {
    _backdropElement = new DivElement()
      ..classes.addAll(['md-overlay-backdrop', _state.backdropClass]);
    _pane.parent.append(_backdropElement);

    // Forward backdrop clicks such that the consumer of the overlay can perform whatever
    // action desired when such a click occurs (usually closing the overlay).
    backdropClick = _backdropElement.onClick;

    // Add class to fade-in the backdrop after one frame.
    window.animationFrame.then/*<num>*/((num _) {
      if (_backdropElement != null) {
        _backdropElement.classes.add('md-overlay-backdrop-showing');
      }
    });
  }

  /// Detaches the backdrop (if any) associated with the overlay.
  void _detachBackdrop() {
    var backdropToDetach = _backdropElement;

    if (backdropToDetach != null) {
      var finishDetach = () {
        // It may not be attached to anything in certain cases (e.g. unit tests).
        if (backdropToDetach != null && backdropToDetach.parentNode != null) {
          backdropToDetach.remove();
        }

        // It is possible that a new portal has been attached to this overlay since we started
        // removing the backdrop. If that is the case, only clear the backdrop reference if it
        // is still the same instance that we started to remove.
        if (_backdropElement == backdropToDetach) {
          _backdropElement = null;
        }
      };

      backdropToDetach
        ..classes
            .removeAll(['md-overlay-backdrop-showing', _state.backdropClass])
        ..onTransitionEnd.listen((_) => finishDetach());

      // If the backdrop doesn't have a transition, the `transitionend` event won't fire.
      // In this case we make it unclickable and we try to remove it after a delay.
      backdropToDetach.style.pointerEvents = 'none';
      new Timer(new Duration(milliseconds: 500), () => finishDetach());
    }
  }
}

// value: num | String
String formatCssUnit(dynamic value) => value is String ? value : '${value}px';
