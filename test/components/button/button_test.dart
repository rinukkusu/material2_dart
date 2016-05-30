import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2_testing/angular2_testing.dart';
import 'package:material2_dart/components/button/button.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  TestComponentBuilder builder;

  initAngularTests();

  setUpProviders(() => [TestComponentBuilder]);

  ngSetUp((TestComponentBuilder tcb) {
    builder = tcb;
  });

  ngTest('should apply class based on color attribute', () async {
    ComponentFixture fixture = await builder.createAsync(TestApp);
    var testComponent = fixture.debugElement.componentInstance;
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
    var testComponent = fixture.debugElement.componentInstance;
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
    ngTest('should handle a click on the button', () async {});
    ngTest('should not increment if disabled', () async {});
  }, skip: "TODO: how to simulate click event?");

  group('a[md-button]', () {
    ngTest('should not redirect if disabled', () async {},
        skip: "TODO: how to simulate click event?");
    ngTest('should remove tabindex if disabled', () async {},
        skip: "TODO: how to simulate click event?");
    ngTest('should add aria-disabled attribute if disabled', () async {
      ComponentFixture fixture = await builder.createAsync(TestApp);
      var testComponent = fixture.debugElement.componentInstance;
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
