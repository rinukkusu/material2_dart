import 'dart:html';
import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2_testing/angular2_testing.dart';
import 'package:material2_dart/components/button/button.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  TestComponentBuilder builder;

  initAngularTests();

  setUpProviders(() {
    return const [
      const Provider(TestComponentBuilder, useClass: TestComponentBuilder)
    ];
  });

  ngSetUp((TestComponentBuilder tcb) {
    builder = tcb;
  });

  ngTest('should apply class based on color attribute', () async {
    ComponentFixture fixture = await builder.createAsync(TestApp);
    dynamic testComponent = fixture.debugElement.componentInstance;
    var buttonDebugElement = fixture.debugElement.query(By.css('button'));
    var aDebugElement = fixture.debugElement.query(By.css('a'));

    testComponent.buttonColor = 'primary';
    fixture.detectChanges();

    expect(buttonDebugElement.nativeElement.classes.contains('md-primary'),
        isTrue);
    expect(aDebugElement.nativeElement.classes.contains('md-primary'), isTrue);
  });

  ngTest('should should not clear previous defined classes', () async {
    ComponentFixture fixture = await builder.createAsync(TestApp);
    dynamic testComponent = fixture.debugElement.componentInstance;
    var buttonDebugElement = fixture.debugElement.query(By.css('button'));

    buttonDebugElement.nativeElement.classes.add('custom-class');

    testComponent.buttonColor = 'primary';
    fixture.detectChanges();

    expect(buttonDebugElement.nativeElement.classes.contains('md-primary'),
        isTrue);
    expect(buttonDebugElement.nativeElement.classes.contains('custom-class'),
        isTrue);

    testComponent.buttonColor = 'accent';
    fixture.detectChanges();

    expect(buttonDebugElement.nativeElement.classes.contains('md-primary'),
        isFalse);
    expect(
        buttonDebugElement.nativeElement.classes.contains('md-accent'), isTrue);
    expect(buttonDebugElement.nativeElement.classes.contains('custom-class'),
        isTrue);
  });

  group('button[md-button]', () {
    ngTest('should handle a click on the button', () async {
      ComponentFixture fixture = await builder.createAsync(TestApp);
      dynamic testComponent = fixture.debugElement.componentInstance;
      var buttonDebugelement = fixture.debugElement.query(By.css('button'));
      Element e = buttonDebugelement.nativeElement as Element;
      e.click();
      expect(testComponent.clickCount, equals(1));
    });
    ngTest('should not increment if disabled', () async {
      ComponentFixture fixture = await builder.createAsync(TestApp);
      TestApp testComponent = fixture.debugElement.componentInstance as TestApp;
      var buttonDebugelement = fixture.debugElement.query(By.css('button'));

      testComponent.isDisabled = true;
      fixture.detectChanges();
      Element e = buttonDebugelement.nativeElement as Element;
      e.click();
      expect(testComponent.clickCount, equals(0));
    });
  });

  group('a[md-button]', () {
    ngTest('should not redirect if disabled', () async {
      ComponentFixture fixture = await builder.createAsync(TestApp);
      TestApp testComponent = fixture.debugElement.componentInstance as TestApp;
      var buttonDebugelement = fixture.debugElement.query(By.css('a'));

      testComponent.isDisabled = true;
      fixture.detectChanges();

      Element e = buttonDebugelement.nativeElement as Element;
      e.click();
      // will error if page reloads.
    },
        skip:
            'FIXME: Can not confirm the error when testComponent.isDisabled is set to false.');

    ngTest('should remove tabindex if disabled', () async {
      ComponentFixture fixture = await builder.createAsync(TestApp);
      TestApp testComponent = fixture.debugElement.componentInstance as TestApp;
      var buttonDebugelement = fixture.debugElement.query(By.css('a'));
      Element e = buttonDebugelement.nativeElement as Element;
      expect(e.attributes['tabIndex'], isNull);

      testComponent.isDisabled = true;
      fixture.detectChanges();
      expect(e.attributes['tabIndex'], equals('-1'));
    });
    ngTest('should add aria-disabled attribute if disabled', () async {
      ComponentFixture fixture = await builder.createAsync(TestApp);
      dynamic testComponent = fixture.debugElement.componentInstance;
      var buttonDebugElement = fixture.debugElement.query(By.css('a'));
      fixture.detectChanges();
      expect(buttonDebugElement.nativeElement.attributes['aria-disabled'],
          equals('false'));

      testComponent.isDisabled = true;
      fixture.detectChanges();
      expect(buttonDebugElement.nativeElement.attributes['aria-disabled'],
          equals('true'));
    });
  });
}

/// Test component that contains an MdButton.
@Component(
    selector: 'test-app',
    template: '''
    <button md-button type="button" (click)="increment()"
      [disabled]="isDisabled" [color]="buttonColor">
      Go
    </button>
    <a href="http://www.google.com" md-button [disabled]="isDisabled" [color]="buttonColor">Link</a>
  ''',
    directives: const [MdButton, MdAnchor])
class TestApp {
  int clickCount = 0;
  bool isDisabled = false;
  String buttonColor;

  void increment() {
    clickCount++;
  }
}
