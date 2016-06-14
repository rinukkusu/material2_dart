// Copyright (c) 2016, Adao Jr.. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'package:angular2/core.dart';
import 'package:angular2/router.dart';
import 'package:material2_dart/components.dart';
import '../button/button.dart';

@Component(
  selector: 'home',
  template: '''
  <p>Welcome to the development demos for Angular Material 2!</p>
  <p>Open the sidenav to select a demo. </p>
  ''')
class Home {}

@Component(
    selector: 'my-app',
    templateUrl: 'app.html',
    styleUrls: const ['app.css'],
    viewProviders: const [MdIconRegistry],
    directives: const [
      ROUTER_DIRECTIVES,
      MD_DIRECTIVES,
      Dir,
    ])
@RouteConfig(const [
  const Route(path: '/', component: Home),
  const Route(path: '/button', name: 'Button',component: ButtonDemo)
])
class AppComponent {}
