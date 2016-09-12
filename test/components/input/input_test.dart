import 'dart:html';
import 'package:angular2/core.dart';
import 'package:angular2/testing.dart';
import 'package:angular2_testing/angular2_testing.dart';
import 'package:angular2/platform/browser.dart';
import 'package:material2_dart/components/input/input.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  initAngularTests();

  setUpProviders(() {
    return const [
      const Provider(TestComponentBuilder, useClass: TestComponentBuilder)
    ];
  });

  group('MdInput', () {
    TestComponentBuilder builder;
    ngSetUp((TestComponentBuilder tcb) {
      builder = tcb;
    });
    ngTest('creates a native <input> element', () async {
      var fixture = await builder.createAsync(MdInputBaseTestController);
      fixture.detectChanges();
      expect(fixture.debugElement.query(By.css('input')), isNotNull);
    });

    ngTest('support ngModel', () async {
      var fixture = await builder.createAsync(MdInputBaseTestController);
      fixture.detectChanges();
      fakeAsync(() {
        dynamic instance = fixture.componentInstance;
        dynamic component =
            fixture.debugElement.query(By.directive(MdInput)).componentInstance;
        InputElement el = fixture.debugElement
            .query(By.css('input'))
            .nativeElement as InputElement;

        instance.model = 'hello';
        fixture.detectChanges();
        tick();
        expect(el.value, equals('hello'));
        component.value = 'world';
        fixture.detectChanges();
        tick();
        expect(el.value, equals('world'));
      })();
    });

    ngTest('should have a different ID for outer element and internal input',
        () async {
      var fixture = await builder
          .overrideTemplate(
              MdInputBaseTestController, ' <md-input id="test-id"></md-input>')
          .createAsync(MdInputBaseTestController);
      fixture.detectChanges();
      fakeAsync(() {
        final Element componentElement = fixture.debugElement
            .query(By.directive(MdInput))
            .nativeElement as Element;
        final InputElement inputElement = fixture.debugElement
            .query(By.css('input'))
            .nativeElement as InputElement;
        expect(componentElement.id, equals('test-id'));
        expect(inputElement.id.isNotEmpty, isTrue);
        expect(inputElement.id, isNot(equals(componentElement.id)));
      })();
    });
    ngTest('counts characters', () async {
      var fixture = await builder.createAsync(MdInputBaseTestController);
      dynamic instance = fixture.componentInstance;
      fixture.detectChanges();
      dynamic inputInstance =
          fixture.debugElement.query(By.directive(MdInput)).componentInstance;
      instance.model = 'hello';
      fixture.detectChanges();
      expect(inputInstance.characterCount, equals(5));
    });
    ngTest('copies aria attributes to the inner input', () async {
      var fixture = await builder.createAsync(MdInputAriaTestController);
      dynamic instance = fixture.componentInstance;
      fixture.detectChanges();
      InputElement el = fixture.debugElement
          .query(By.css('input'))
          .nativeElement as InputElement;
      expect(el.attributes['aria-label'], equals('label'));
      instance.ariaLabel = 'label 2';
      fixture.detectChanges();
      expect(el.getAttribute('aria-label'), equals('label 2'));
      expect(el.getAttribute('aria-disabled'), isNotNull);
    });
  });

  /// TODO(ntaoo): Porting tests is in progress.
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input type="number" [(ngModel)]="value">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputNumberTypeConservedTestComponent {
  int value = 0;
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input required placeholder="hello">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputPlaceholderRequiredTestComponent {}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input>
      <md-placeholder>{{placeholder}}</md-placeholder>
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputPlaceholderElementTestComponent {
  String placeholder = 'Default Placeholder';
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input [placeholder]="placeholder">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputPlaceholderAttrTestComponent {
  String placeholder = '';
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input>
      <md-hint>{{label}}</md-hint>
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputHintLabel2TestController {
  String label = '';
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input [hintLabel]="label">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputHintLabelTestController {
  String label = '';
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input type="file">
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputInvalidTypeTestController {}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input placeholder="Hello">
      <md-placeholder>World</md-placeholder>
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputInvalidPlaceholderTestController {}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input hintLabel="Hello">
      <md-hint>World</md-hint>
    </md-input>
  ''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputInvalidHint2TestController {}

@Component(
    selector: 'test-input-controller',
    template: '''
<md-input>
<md-hint>Hello</md-hint>
<md-hint>World</md-hint>
</md-input>
''',
    directives: const [MD_INPUT_DIRECTIVES])
class MdInputInvalidHintTestController {}

@Component(
    selector: 'test-input-controller',
    template: '''
<md-input [(ngModel)]="model">
</md-input>
''',
    directives: const [MdInput])
class MdInputBaseTestController {
  dynamic model = '';
}

@Component(
    selector: 'test-input-controller',
    template: '''
      <md-input [aria-label]="ariaLabel" [aria-disabled]="ariaDisabled">
      </md-input>
    ''',
    directives: const [MdInput])
class MdInputAriaTestController {
  String ariaLabel = 'label';
  bool ariaDisabled = true;
}

@Component(
    selector: 'test-input-controller',
    template: r'''
<md-input (focus)="onFocus($event)" (blur)="onBlur($event)"></md-input>
''',
    directives: const [MdInput])
class MdInputWithBlurAndFocusEvents {
  void onBlur(FocusEvent event) {}

  void onFocus(FocusEvent event) {}
}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input></md-input>
    ''',
    directives: const [MdInput])
class MdInputOptionalAttributeController {}

@Component(
    selector: 'test-input-controller',
    template: '''
    <md-input name="some-name"></md-input>
  ''',
    directives: const [MdInput])
class MdInputWithNameTestController {}
