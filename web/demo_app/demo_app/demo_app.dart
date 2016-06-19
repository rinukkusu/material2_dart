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

import '../button/button_demo.dart';
import '../card/card_demo.dart';
import '../icon/icon_demo.dart';

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
      'demo_app.css'
    ],
    providers: const [
      ROUTER_PROVIDERS,
      MdIconRegistry
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
  const Route(path: '/card', name: 'Card', component: CardDemo),
  const Route(path: '/icon', name: 'Icon', component: IconDemo)
])
class DemoApp {
  Router router;

  DemoApp(this.router);
}
