import "dart:html";
import "dart:async";
import "package:angular2/core.dart";
import "overlay_state.dart";
import "../portal/dom_portal_host.dart";
import "overlay_ref.dart";
import "position/overlay_position_builder.dart";
import "position/viewport_ruler.dart";

export 'position/connected_position.dart';
export 'overlay_container.dart';

/** Token used to inject the DOM element that serves as the overlay container. */
const OpaqueToken OVERLAY_CONTAINER_TOKEN = const OpaqueToken("overlayContainer");
/** Next overlay unique ID. */
int nextUniqueId = 0;
/** The default state for newly created overlays. */
OverlayState defaultState = new OverlayState();

/**
 * Service to create Overlays. Overlays are dynamically added pieces of floating UI, meant to be
 * used as a low-level building building block for other components. Dialogs, tooltips, menus,
 * selects, etc. can all be built using overlays. The service should primarily be used by authors
 * of re-usable components rather than developers building end-user applications.
 *
 * An overlay *is* a PortalHost, so any kind of Portal can be loaded into one.
 */
@Injectable()
class Overlay {
  Element _overlayContainerElement;
  ComponentResolver _componentResolver;
  OverlayPositionBuilder _positionBuilder;

  Overlay(@Inject(OVERLAY_CONTAINER_TOKEN) this._overlayContainerElement,
      this._componentResolver, this._positionBuilder);

  /**
   * Creates an overlay.
   */
  Future<OverlayRef> create([OverlayState state]) async {
    state ??= defaultState;
    DivElement pane = await _createPaneElement();
    return _createOverlayRef(pane, state);
  }

  /**
   * Returns a position builder that can be used, via fluent API,
   * to construct and configure a position strategy.
   */
  OverlayPositionBuilder position() => _positionBuilder;

  /**
   * Creates the DOM element for an overlay and appends it to the overlay container.
   */
  Future<DivElement> _createPaneElement() {
    DivElement pane = new DivElement()
      ..id = 'md-overlay-${nextUniqueId++}'
      ..classes.add("md-overlay-pane");
    _overlayContainerElement.append(pane);
    return new Future.value(pane);
  }

  /**
   * Create a DomPortalHost into which the overlay content can be loaded.
   */
  DomPortalHost _createPortalHost(DivElement pane) =>
      new DomPortalHost(pane, _componentResolver);

  /**
   * Creates an OverlayRef for an overlay in the given DOM element.
   */
  OverlayRef _createOverlayRef(DivElement pane, OverlayState state) =>
      new OverlayRef(_createPortalHost(pane), pane, state);
}

/** Providers for Overlay and its related injectables. */
const List OVERLAY_PROVIDERS = const [
  ViewportRuler,
  OverlayPositionBuilder,
  Overlay
];
