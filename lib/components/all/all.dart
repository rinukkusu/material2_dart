import '../button/button.dart';
import '../button_toggle/button_toggle.dart';
import '../card/card.dart';
import '../checkbox/checkbox.dart';
import '../grid_list/grid_list.dart';
import '../icon/icon.dart';
import '../input/input.dart';
import '../list/list.dart';
import '../progress_bar/progress_bar.dart';
import '../progress_circle/progress_circle.dart';
import '../radio/radio.dart';
import '../sidenav/sidenav.dart';
import '../slide_toggle/slide_toggle.dart';
import '../tabs/tabs.dart';
import '../toolbar/toolbar.dart';

import '../../core/overlay/overlay.dart';
import '../../core/ripple/ripple.dart';
import '../../core/portal/portal_directives.dart';
import '../../core/overlay/overlay_directives.dart';
import '../../core/rtl/dir.dart';
import '../../core/a11y/live_announcer.dart';

const List MATERIAL_DIRECTIVES = const <dynamic>[
  MD_BUTTON_DIRECTIVES,
  MD_CARD_DIRECTIVES,
  MD_CHECKBOX_DIRECTIVES,
  MD_GRID_LIST_DIRECTIVES,
  MD_ICON_DIRECTIVES,
  MD_INPUT_DIRECTIVES,
  MD_LIST_DIRECTIVES,
  MD_PROGRESS_BAR_DIRECTIVES,
  MD_PROGRESS_CIRCLE_DIRECTIVES,
  MD_RADIO_DIRECTIVES,
  MD_RIPPLE_DIRECTIVES,
  MD_SIDENAV_DIRECTIVES,
  MD_SLIDE_TOGGLE_DIRECTIVES,
  MD_TABS_DIRECTIVES,
  MD_TOOLBAR_DIRECTIVES,
  PORTAL_DIRECTIVES,
  OVERLAY_DIRECTIVES,
  RTL_DIRECTIVES,
];

const List MATERIAL_PROVIDERS = const <dynamic>[
  OVERLAY_PROVIDERS,
  MdLiveAnnouncer
];
