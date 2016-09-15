import 'line/line.dart';
import 'rtl/dir.dart';
import 'ripple/ripple.dart';
import 'portal/portal_directives.dart';
import 'overlay/overlay_directives.dart';
import 'overlay/overlay.dart';
import "a11y/live_announcer.dart";

// TODO(ntaoo): export LayoutDirection.
export "rtl/dir.dart" show Dir;
export "portal/portal.dart"
    show Portal, PortalHost, BasePortalHost, ComponentPortal, TemplatePortal;
export "portal/portal_directives.dart"
    show PortalHostDirective, TemplatePortalDirective, PORTAL_DIRECTIVES;
export "portal/dom_portal_host.dart" show DomPortalHost;
export "overlay/overlay.dart" show Overlay, OVERLAY_PROVIDERS;
export "overlay/overlay_container.dart" show OverlayContainer;
export "overlay/overlay_ref.dart" show OverlayRef;
export "overlay/overlay_state.dart" show OverlayState;
export "overlay/overlay_directives.dart"
    show ConnectedOverlayDirective, OverlayOrigin, OVERLAY_DIRECTIVES;
export "overlay/position/connected_position.dart"
    show
        OverlayConnectionPosition,
        OriginConnectionPosition,
        HorizontalConnectionPos,
        VerticalConnectionPos;
export "ripple/ripple.dart" show MD_RIPPLE_DIRECTIVES, MdRipple;
//export "gestures/MdGestureConfig.dart";
export "a11y/live_announcer.dart"
    show MdLiveAnnouncer, LIVE_ANNOUNCER_ELEMENT_TOKEN;
export "coordination/unique_selection_dispatcher.dart"
    show MdUniqueSelectionDispatcher, MdUniqueSelectionDispatcherListener;
export "line/line.dart" show MdLine, MdLineSetter;

const List CORE_DIRECTIVES = const <dynamic>[
  MdLine,
  RTL_DIRECTIVES,
  MdRipple,
  PORTAL_DIRECTIVES,
  OVERLAY_DIRECTIVES,
];

const List CORE_PROVIDERS = const <dynamic>[
  OVERLAY_PROVIDERS,
  MdLiveAnnouncer,
];
