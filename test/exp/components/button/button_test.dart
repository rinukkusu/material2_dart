@Tags(const ['codegen'])
@TestOn('browser')
library material2_dart.test.exp.components.button.button_test;

import 'dart:html';
import 'package:angular2/angular2.dart';
import 'package:angular2/testing_experimental.dart';
import 'package:test/test.dart';
import 'package:material2_dart/src/components/button/button.dart';

/// pub serve test
///  pub run test --pub-serve=8080 -t codegen -p content-shell test/exp/components/button/button_test.dart
@AngularEntrypoint()
void main() {
  tearDown(() => disposeAnyRunningTest());
  test('should apply class based on color attribute', () async {
    var testBed = new NgTestBed<TestApp>();
    NgTestFixture fixture = await testBed.create();
    await fixture.update((TestApp testApp) {
      testApp.buttonColor = 'primary';
    });
    Element button = fixture.element.querySelector('button');
    expect(button.classes.contains('md-primary'), isTrue);
  });
}

/// Test component that contains an MdButton.
@Component(
    selector: 'test-app',
    template: '''
    <button md-button type="button" (click)="increment()"
      [disabled]="isDisabled" [color]="buttonColor" [disableRipple]="rippleDisabled">
      Go
    </button>
    <a href="http://www.google.com" md-button [disabled]="isDisabled" [color]="buttonColor">Link</a>
  ''',
    directives: const [MdButton, MdAnchor])
class TestApp {
  int clickCount = 0;
  bool isDisabled = false;
  String buttonColor;
  bool rippleDisabled = false;

  void increment() {
    clickCount++;
  }
}
