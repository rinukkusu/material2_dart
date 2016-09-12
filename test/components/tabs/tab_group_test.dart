//import 'dart:html';

//import 'dart:async';
import 'dart:html';
import 'package:angular2/core.dart';

//import 'package:angular2/common.dart';
import 'package:angular2/testing.dart';
import 'package:angular2/platform/browser.dart';
import 'package:angular2_testing/angular2_testing.dart';
import 'package:material2_dart/components/tabs/tabs.dart';
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
  // FIXME: package:test doesn't support test double like spyOn. I may try to port spyOn from package:guiness to an individual package, or use some other mock package.

  group('MdTabGroup', () {
    ComponentFixture fixture;

    /**
     * Checks that the `selectedIndex` has been updated; checks that the label and body have the
     * `md-active` class
     */
    void checkSelectedIndex(int index) {
      fixture.detectChanges();

      MdTabGroup tabComponent = fixture.debugElement
          .query(By.css('md-tab-group'))
          .componentInstance as MdTabGroup;
      expect(tabComponent.selectedIndex, equals(index));

      Element tabLabelElement = fixture.debugElement
          .query(By.css('.md-tab-label:nth-of-type(${index + 1})'))
          .nativeElement as Element;
      expect(tabLabelElement.classes.contains('md-active'), isTrue);

      Element tabContentElement = fixture.debugElement
          .query(By.css('#${tabLabelElement.id}'))
          .nativeElement as Element;
      expect(tabContentElement.classes.contains('md-active'), isTrue);
    }

    ngSetUp((TestComponentBuilder tcb) {
      builder = tcb;
    });

    group('basic behavior', () {
      ngSetUp(() async {
        fixture = await builder.createAsync(SimpleTabsTestApp);
      });

      ngTest('should default to the first tab', () {
        checkSelectedIndex(1);
      });

      ngTest('should change selected index on click', () {
        SimpleTabsTestApp component = fixture.debugElement.componentInstance as SimpleTabsTestApp;
        component.selectedIndex = 0;
        checkSelectedIndex(0);

        // select the second tab
        var tabLabel =
            fixture.debugElement.query(By.css('.md-tab-label:nth-of-type(2)'));
        tabLabel.nativeElement.click();
        checkSelectedIndex(1);

        // select the third tab
        tabLabel =
            fixture.debugElement.query(By.css('.md-tab-label:nth-of-type(3)'));
        tabLabel.nativeElement.click();
        checkSelectedIndex(2);
      });

      ngTest(
          'should cycle through tab focus with focusNextTab/focusPreviousTab functions',
          () {
        fakeAsync(() async {
          dynamic testComponent = fixture.componentInstance;
          var tabComponent = fixture.debugElement
              .query(By.css('md-tab-group'))
              .componentInstance as MdTabGroup;
//          spyOn(testComponent, 'handleFocus').and.callThrough();
          fixture.detectChanges();

          tabComponent.focusIndex = 0;
          fixture.detectChanges();
          tick();
          expect(tabComponent.focusIndex, equals(0));
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(1);
          expect(testComponent.focusEvent.index, equals(0));

          tabComponent.focusNextTab();
          fixture.detectChanges();
          tick();
          expect(tabComponent.focusIndex, equals(1));
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(2);
          expect(testComponent.focusEvent.index, equals(1));

          tabComponent.focusNextTab();
          fixture.detectChanges();
          tick();
          expect(tabComponent.focusIndex, equals(2));
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(3);
          expect(testComponent.focusEvent.index, equals(2));

          tabComponent.focusNextTab();
          fixture.detectChanges();
          tick();
          expect(tabComponent.focusIndex, equals(2)); // should stop at 2
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(3);
          expect(testComponent.focusEvent.index, equals(2));

          tabComponent.focusPreviousTab();
          fixture.detectChanges();
          tick();
          expect(tabComponent.focusIndex, equals(1));
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(4);
          expect(testComponent.focusEvent.index, equals(1));

          tabComponent.focusPreviousTab();
          fixture.detectChanges();
          tick();
          expect(tabComponent.focusIndex, equals(0));
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(5);
          expect(testComponent.focusEvent.index, equals(0));

          tabComponent.focusPreviousTab();
          fixture.detectChanges();
          tick();
          expect(tabComponent.focusIndex, equals(0)); // should stop at 0
//          expect(testComponent.handleFocus).toHaveBeenCalledTimes(5);
          expect(testComponent.focusEvent.index, equals(0));
        })();
      });

      ngTest('should change tabs based on selectedIndex', () {
        fakeAsync(() {
          dynamic component = fixture.componentInstance;
          var tabComponent = fixture.debugElement
              .query(By.css('md-tab-group'))
              .componentInstance as MdTabGroup;

//          spyOn(component, 'handleSelection').and.callThrough();

          checkSelectedIndex(1);

          tabComponent.selectedIndex = 2;

          checkSelectedIndex(2);
          tick();

//          expect(component.handleSelection).toHaveBeenCalledTimes(1);
          expect(component.selectEvent.index, equals(2));
        })();
      });
      group('async tabs', () {
        // FIXME: Waiting for ng2 updated to greater than rc2 and whenStable() is supported.
//        ngSetUp(() async {
//          fixture = await builder.createAsync(AsyncTabsTestApp);
//        });

//        ngTest('should show tabs when they are available', () {
//          var labels = fixture.debugElement.queryAll(By.css('.md-tab-label'));
//
//          expect(labels.length, equals(0));
//
//          fixture.detectChanges();

        // https://github.com/angular/angular/issues/8617
//          fixture.whenStable().then(() {
//          fixture.detectChanges();
//          labels = fixture.debugElement.queryAll(By.css('.md-tab-label'));
//          expect(labels.length, equals(2));
//        });
//       });
      });
    });
  });
}

@Component(
    selector: 'test-app',
    template: r'''
    <md-tab-group class="tab-group"
        [selectedIndex]="selectedIndex"
        (focusChange)="handleFocus($event)"
        (selectChange)="handleSelection($event)">
      <md-tab>
        <template md-tab-label>Tab One</template>
        <template md-tab-content>Tab one content</template>
      </md-tab>
      <md-tab>
        <template md-tab-label>Tab Two</template>
        <template md-tab-content>Tab two content</template>
      </md-tab>
      <md-tab>
        <template md-tab-label>Tab Three</template>
        <template md-tab-content>Tab three content</template>
      </md-tab>
    </md-tab-group>
  ''',
    directives: const [MD_TABS_DIRECTIVES])
class SimpleTabsTestApp {
  int selectedIndex = 1;
  dynamic focusEvent;
  dynamic selectEvent;

  void handleFocus(dynamic event) {
    focusEvent = event;
  }

  void handleSelection(dynamic event) {
    selectEvent = event;
  }
}

//@Component(
//    selector: 'test-app',
//    template: '''
//    <md-tab-group class="tab-group">
//      <md-tab *ngFor="let tab of tabs | async">
//        <template md-tab-label>{{ tab.label }}</template>
//        <template md-tab-content>{{ tab.content }}</template>
//      </md-tab>
//   </md-tab-group>
//  ''',
//    directives: const [MD_TABS_DIRECTIVES],
//    pipes: const [AsyncPipe])
//class AsyncTabsTestApp {
//  List<Map> _tabs = [
//    {'label': 'one', 'content': 'one'},
//    {'label': 'two', 'content': 'two'}
//  ];
//
//  Stream<dynamic> tabs;
//
//  AsyncTabsTestApp() {
//    tabs = window.animationFrame.then((_) => _tabs).asStream();
//  }
//}
