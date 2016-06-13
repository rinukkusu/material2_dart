import 'dart:async';
import 'package:angular2/core.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2_testing/angular2_testing.dart';
import 'package:material2_dart/components/list/list.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
  TestComponentBuilder builder;

  initAngularTests();

  group('MdList', () {
    setUpProviders(() {
      return const [
        const Provider(TestComponentBuilder, useClass: TestComponentBuilder)
      ];
    });

    ngSetUp((TestComponentBuilder tcb) {
      builder = tcb;
    });

    ngTest('should add and remove focus class on focus/blur', () async {
      var template = '''
        <md-list>
          <a md-list-item>
            Paprika
          </a>
        </md-list>
      ''';
      ComponentFixture fixture = await builder
          .overrideTemplate(TestList, template)
          .createAsync(TestList);
      var listItem = fixture.debugElement.query(By.directive(MdListItem));
      var listItemDiv = fixture.debugElement.query(By.css('.md-list-item'));
      fixture.detectChanges();
      expect(listItemDiv.nativeElement.classes,
          isNot(contains('md-list-item-focus')));
      MdListItem mdListItem = listItem.componentInstance;
      mdListItem.handleFocus();
      fixture.detectChanges();
      expect(listItemDiv.nativeElement.classes, contains('md-list-item-focus'));

      MdListItem mdListItem2 = listItem.componentInstance;
      mdListItem2.handleBlur();
      fixture.detectChanges();
      expect(listItemDiv.nativeElement.classes,
          isNot(contains('md-list-item-focus')));
    });

    ngTest('should not apply any class to a list without lines', () async {
      var template = '''
        <md-list>
          <md-list-item>
            Paprika
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture = await builder
          .overrideTemplate(TestList, template)
          .createAsync(TestList);
      var listItem = fixture.debugElement.query(By.css('md-list-item'));
      fixture.detectChanges();
      expect(listItem.nativeElement.className, isEmpty);
    });

    ngTest('should apply md-2-line class to lists with two lines', () async {
      var template = '''
        <md-list>
          <md-list-item *ngFor="let item of items">
            <img src="">
            <h3 md-line>{{item['name']}}</h3>
            <p md-line>{{item['description']}}</p>
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture = await builder
          .overrideTemplate(TestList, template)
          .createAsync(TestList);
      fixture.detectChanges();
      var listItems =
          fixture.debugElement.children.first.queryAll(By.css('md-list-item'));
      expect(listItems[0].nativeElement.className, equals('md-2-line'));
      expect(listItems[1].nativeElement.className, equals('md-2-line'));
    });

    ngTest('should apply md-3-line class to lists with three lines', () async {
      var template = '''
        <md-list>
          <md-list-item *ngFor="let item of items">
            <h3 md-line>{{item['name']}}</h3>
            <p md-line>{{item['description']}}</p>
            <p md-line>Some other text</p>
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture = await builder
          .overrideTemplate(TestList, template)
          .createAsync(TestList);
      fixture.detectChanges();
      var listItems =
          fixture.debugElement.children.first.queryAll(By.css('md-list-item'));
      expect(listItems[0].nativeElement.className, equals('md-3-line'));
      expect(listItems[1].nativeElement.className, equals('md-3-line'));
    });

    ngTest('should apply md-list-avatar class to list items with avatars',
        () async {
      var template = '''
        <md-list>
          <md-list-item>
            <img src="" md-list-avatar>
            Paprika
          </md-list-item>
         <md-list-item>
            Pepper
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture = await builder
          .overrideTemplate(TestList, template)
          .createAsync(TestList);
      fixture.detectChanges();
      var listItems =
          fixture.debugElement.children.first.queryAll(By.css('md-list-item'));
      expect(listItems[0].nativeElement.className, equals('md-list-avatar'));
      expect(listItems[1].nativeElement.className, isEmpty);
    });

    ngTest('should not clear custom classes provided by user', () async {
      var template = '''
        <md-list>
          <md-list-item class="test-class" *ngFor="let item of items">
            <h3 md-line>{{item['name']}}</h3>
            <p md-line>{{item['description']}}</p>
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture = await builder
          .overrideTemplate(TestList, template)
          .createAsync(TestList);
      fixture.detectChanges();
      var listItems =
          fixture.debugElement.children.first.queryAll(By.css('md-list-item'));
      expect(listItems[0].nativeElement.classes, contains('test-class'));
    });

    ngTest('should update classes if number of lines change', () async {
      var template = '''
        <md-list>
          <md-list-item *ngFor="let item of items">
            <h3 md-line>{{item['name']}}</h3>
            <p md-line>{{item['description']}}</p>
            <p md-line *ngIf="showThirdLine">Some other text</p>
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture = await builder
          .overrideTemplate(TestList, template)
          .createAsync(TestList);
      fixture.debugElement.componentInstance.showThirdLine = false;
      fixture.detectChanges();
      var listItem =
          fixture.debugElement.children.first.query(By.css('md-list-item'));
      expect(listItem.nativeElement.className, equals('md-2-line'));

      fixture.debugElement.componentInstance.showThirdLine = true;
      fixture.detectChanges();
      new Future.microtask(() {
        expect(listItem.nativeElement.className, equals('md-3-line'));
      });
    });

    ngTest('should add aria roles properly', () async {
      var template = '''
        <md-list>
          <md-list-item *ngFor="let item of items">
            {{item['name']}}
          </md-list-item>
        </md-list>
      ''';
      ComponentFixture fixture = await builder
          .overrideTemplate(TestList, template)
          .createAsync(TestList);
      fixture.detectChanges();
      var list = fixture.debugElement.children.first;
      var listItem =
          fixture.debugElement.children.first.query(By.css('md-list-item'));
      expect(list.nativeElement.attributes['role'], equals('list'));
      expect(listItem.nativeElement.attributes['role'], equals('listitem'));
    });
  });
}

@Component(
    selector: 'test-list', template: '', directives: const [MD_LIST_DIRECTIVES])
class TestList {
  List<Map> items = [
    {'name': 'Paprika', 'description': 'A seasoning'},
    {'name': 'Pepper', 'description': 'Another seasoning'}
  ];
  bool showThirdLine = false;
}
