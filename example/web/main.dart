import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';
import 'package:material2_dart/core/overlay/overlay.dart';
import 'package:material2_dart_example/demo_app/demo_app.dart';

main() {
  bootstrap(DemoApp, [
    new Provider(OVERLAY_CONTAINER_TOKEN, useValue: createOverlayContainer()),
  ]);
}
