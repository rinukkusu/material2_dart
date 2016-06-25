// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.
import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:material2_dart/core/rtl/dir.dart';
import 'package:material2_dart/components/button/button.dart';
import 'package:material2_dart/components/sidenav/sidenav.dart';
import 'package:material2_dart/components/icon/icon.dart';
import 'package:material2_dart/components/icon/icon_registry.dart';
import 'package:material2_dart/components/list/list.dart';
import 'package:material2_dart/components/toolbar/toolbar.dart';

import '../baseline/baseline_demo.dart';
import '../button/button_demo.dart';

//import '../button_toggle/button_toggle_demo.dart';
import '../card/card_demo.dart';
import '../checkbox/checkbox_demo.dart';
import '../grid_list/grid_list_demo.dart';
import '../icon/icon_demo.dart';
import '../input/input_demo.dart';
import '../list/list_demo.dart';
import '../overlay/overlay_demo.dart';
import '../radio/radio_demo.dart';
import '../sidenav/sidenav_demo.dart';
import '../slide_toggle/slide_toggle_demo.dart';
import '../toolbar/toolbar_demo.dart';
import '../tabs/tab_group_demo.dart';

@Component(
    selector: 'home',
    template: '''
    <p>Welcome to the development demos for Angular Material 2!</p>
    <p>Open the sidenav to select a demo. </p>
  ''')
class Home {}

@Component(
    selector: 'demo-app',
    templateUrl: 'demo_app.html',
    styleUrls: const [
      'demo_app.scss.css'
    ],
    providers: const [
      ROUTER_PROVIDERS,
      MdIconRegistry,
      Renderer
    ],
    directives: const [
      ROUTER_DIRECTIVES,
      Dir,
      MdButton,
      MdIcon,
      MD_SIDENAV_DIRECTIVES,
      MD_LIST_DIRECTIVES,
      MdToolbar
    ])
@RouteConfig(const [
  const Route(path: '/', name: 'Home', component: Home, useAsDefault: true),
  const Route(path: '/button', name: 'Button', component: ButtonDemo),
  const Route(path: '/baseline', name: 'Baseline', component: BaselineDemo),
//  const Route(
//      path: '/button-toggle', name: 'ButtonToggle', component: ButtonToggleDemo),
  const Route(path: '/card', name: 'Card', component: CardDemo),
  const Route(path: '/checkbox', name: 'Checkbox', component: CheckboxDemo),
  const Route(path: '/grid-list', name: 'GridList', component: GridListDemo),
  const Route(path: '/icon', name: 'Icon', component: IconDemo),
  const Route(path: '/input', name: 'Input', component: InputDemo),
  const Route(path: '/list', name: 'List', component: ListDemo),
  const Route(path: '/overlay', name: 'Overlay', component: OverlayDemo),
  const Route(path: '/radio', name: 'Radio', component: RadioDemo),
  const Route(
      path: '/slide-toggle', name: 'SlideToggle', component: SlideToggleDemo),
  const Route(path: '/sidenav', name: 'Sidenav', component: SidenavDemo),
  const Route(path: '/toolbar', name: 'Toolbar', component: ToolbarDemo),
  const Route(path: '/tabs', name: 'Tabs', component: TabsDemo)
])
class DemoApp {
  Router router;

  DemoApp(this.router);
}
