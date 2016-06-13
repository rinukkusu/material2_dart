// Copyright (c) 2016, <your name>. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:material2_dart/components/button/button.dart';
import 'package:material2_dart/components/sidenav/sidenav.dart';

//import '../button/button_demo.dart';

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
    styleUrls: const ['demo_app.scss.css'],
    providers: const [ROUTER_PROVIDERS],
    directives: const [ROUTER_DIRECTIVES, MdButton, MD_SIDENAV_DIRECTIVES])
@RouteConfig(const [
  const Route(path: '/', name: 'Home', component: Home, useAsDefault: true)
//  const Route(path: '/button', name: 'Button', component: ButtonDemo)
])
class DemoApp {
  Router router;

  DemoApp(this.router);
}
