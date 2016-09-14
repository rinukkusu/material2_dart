import 'dart:async';
import "package:angular2/core.dart";
import "overlay.dart";
import "overlay_ref.dart";
import "../portal/portal.dart";
import "overlay_state.dart";
import "position/connected_position.dart";

/** Default set of positions for the overlay. Follows the behavior of a dropdown. */
List<ConnectionPositionPair> defaultPositionList = [
  new ConnectionPositionPair(
      new OriginConnectionPosition(
          HorizontalConnectionPos.start, VerticalConnectionPos.bottom),
      new OverlayConnectionPosition(
          HorizontalConnectionPos.start, VerticalConnectionPos.top)),
  new ConnectionPositionPair(
      new OriginConnectionPosition(
          HorizontalConnectionPos.start, VerticalConnectionPos.top),
      new OverlayConnectionPosition(
          HorizontalConnectionPos.start, VerticalConnectionPos.bottom)),
];

/**
 * Directive applied to an element to make it usable as an origin for an Overlay using a
 * ConnectedPositionStrategy.
 */
@Directive(selector: "[overlay-origin]", exportAs: "overlayOrigin")
class OverlayOrigin {
  ElementRef _elementRef;

  OverlayOrigin(this._elementRef);

  ElementRef get elementRef => _elementRef;
}

/**
 * Directive to facilitate declarative creation of an Overlay using a ConnectedPositionStrategy.
 */
@Directive(selector: "[connected-overlay]")
class ConnectedOverlayDirective implements OnInit, OnDestroy {
  Overlay _overlay;
  OverlayRef _overlayRef;
  TemplatePortal _templatePortal;
  @Input()
  OverlayOrigin origin;
  @Input()
  List<ConnectionPositionPair> positions;

  // TODO(jelbourn): inputs for size, scroll behavior, animation, etc.
  ConnectedOverlayDirective(
      this._overlay, TemplateRef templateRef, ViewContainerRef viewContainerRef)
      : _templatePortal = new TemplatePortal(templateRef, viewContainerRef);

  OverlayRef get overlayRef => _overlayRef;

  @override
  void ngOnInit() {
    _createOverlay();
  }

  @override
  void ngOnDestroy() {
    _destroyOverlay();
  }

  /** Creates an overlay and attaches this directive's template to it. */
  Future<Null> _createOverlay() async {
    if (positions == null || positions.length != 0) {
      positions = defaultPositionList;
    }
    OverlayState overlayConfig = new OverlayState();
    overlayConfig.positionStrategy = _overlay.position().connectedTo(
        origin.elementRef,
        new OriginConnectionPosition(
            positions[0].overlayX, positions[0].originY),
        new OverlayConnectionPosition(
            positions[0].overlayX, positions[0].overlayY));
    OverlayRef ref = await _overlay.create(overlayConfig);
    _overlayRef = ref;
    await _overlayRef.attach(_templatePortal);
  }

  /** Destroys the overlay created by this directive. */
  void _destroyOverlay() {
    _overlayRef.dispose();
  }
}

const List OVERLAY_DIRECTIVES = const [ConnectedOverlayDirective, OverlayOrigin];
