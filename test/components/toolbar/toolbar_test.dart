import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2_testing/angular2_testing.dart';
import 'package:material2_dart/components/toolbar/toolbar.dart';
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
    var testComponent = fixture.debugElement.componentInstance;
    var toolbarDebugElement = fixture.debugElement.query(By.css('md-toolbar'));

    testComponent.toolbarColor = 'primary';
    fixture.detectChanges();

    expect(toolbarDebugElement.nativeElement.classes.contains('md-primary'),
        isTrue);

    testComponent.toolbarColor = 'accent';
    fixture.detectChanges();

    expect(toolbarDebugElement.nativeElement.classes.contains('md-primary'),
        isFalse);
    expect(toolbarDebugElement.nativeElement.classes.contains('md-accent'),
        isTrue);

    testComponent.toolbarColor = 'warn';
    fixture.detectChanges();

    expect(toolbarDebugElement.nativeElement.classes.contains('md-accent'),
        isFalse);
    expect(
        toolbarDebugElement.nativeElement.classes.contains('md-warn'), isTrue);
  });
}

@Component(
    selector: 'test-app',
    template: '''
    <md-toolbar [color]="toolbarColor">
      <span>Test Toolbar</span>
    </md-toolbar>
  ''',
    directives: const [MdToolbar])
class TestApp {
  String toolbarColor;
}
