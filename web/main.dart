// Copyright (c) 2016, Adao Jr.. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'package:angular2/core.dart';
import 'package:angular2/platform/common.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/router.dart';
import 'demo_app/app.dart';

main() {
  bootstrap(AppComponent, [
    ROUTER_PROVIDERS,
    provide(APP_BASE_HREF, useValue: '/'),
  ]);
}
