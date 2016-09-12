import 'dart:html';
import 'package:angular2/core.dart';
import 'package:angular2/testing.dart';
import 'package:angular2_testing/angular2_testing.dart';
import 'package:material2_dart/core/portal/portal.dart';
import 'package:material2_dart/core/portal/dom_portal_host.dart';
import 'package:material2_dart/core/portal/portal_directives.dart';
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

  group('Portals', () {
    ngSetUp((TestComponentBuilder tcb) {
      builder = tcb;
    });

    group('PortalHostDirective', () {
      ngTest('should load a component into the portal', () {
        fakeAsync(() async {
          ComponentFixture appFixture;
          ComponentFixture fixture = await builder.createAsync(PortalTestApp);
          appFixture = fixture;
          // Flush the async creation of the PortalTestApp.
          flushMicrotasks();
          // Set the selectedHost to be a ComponentPortal.
          PortalTestApp testAppComponent =
              appFixture.debugElement.componentInstance as PortalTestApp;
          testAppComponent.selectedPortal = new ComponentPortal(PizzaMsg);
          appFixture.detectChanges();

          // Flush the attachment of the Portal.
          flushMicrotasks();

          Element hostContainer = appFixture.nativeElement
              .querySelector('.portal-container') as Element;
          expect(hostContainer.text, contains('Pizza'));
        })();
      });

      ngTest('should load a <template> portal', () {
        fakeAsync(() async {
          ComponentFixture appFixture =
              await builder.createAsync(PortalTestApp);

          // Flush the async creation of the PortalTestApp.
          flushMicrotasks();
          // Set the selectedHost to be a ComponentPortal.
          PortalTestApp testAppComponent =
              appFixture.debugElement.componentInstance as PortalTestApp;

          appFixture.detectChanges();
          testAppComponent.selectedPortal = testAppComponent.cakePortal;
          appFixture.detectChanges();

          // Flush the attachment of the Portal.
          flushMicrotasks();

          var hostContainer = appFixture.nativeElement
              .querySelector('.portal-container') as Element;
          expect(hostContainer.text, contains('Cake'));
        })();
      });

      ngTest('should load a <template> portal with the `*` sugar', () {
        fakeAsync(() async {
          ComponentFixture appFixture =
              await builder.createAsync(PortalTestApp);

          // Flush the async creation of the PortalTestApp.
          flushMicrotasks();
          // Set the selectedHost to be a ComponentPortal.
          PortalTestApp testAppComponent =
              appFixture.debugElement.componentInstance as PortalTestApp;

          appFixture.detectChanges();

          testAppComponent.selectedPortal = testAppComponent.piePortal;
          appFixture.detectChanges();

          // Flush the attachment of the Portal.
          flushMicrotasks();

          var hostContainer = appFixture.nativeElement
              .querySelector('.portal-container') as Element;
          expect(hostContainer.text, contains('Pie'));
        })();
      });

      ngTest('should load a <template> portal with a binding', () {
        fakeAsync(() async {
          ComponentFixture appFixture =
              await builder.createAsync(PortalTestApp);

          // Flush the async creation of the PortalTestApp.
          flushMicrotasks();

          // Set the selectedHost to be a ComponentPortal.
          PortalTestApp testAppComponent =
              appFixture.debugElement.componentInstance as PortalTestApp;

          appFixture.detectChanges();

          testAppComponent.selectedPortal = testAppComponent.portalWithBinding;
          appFixture.detectChanges();

          // Flush the attachment of the Portal.
          flushMicrotasks();

          // Now that the portal is attached, change detection has to happen again in order
          // for the bindings to update.
          appFixture.detectChanges();

          // Expect that the content of the attached portal is present.
          var hostContainer = appFixture.nativeElement
              .querySelector('.portal-container') as Element;
          expect(hostContainer.text, contains('Banana'));

          // When updating the binding value.
          testAppComponent.fruit = 'Mango';
          appFixture.detectChanges();

          // Expect the new value to be reflected in the rendered output.
          expect(hostContainer.text, contains('Mango'));
        })();
      });

      ngTest('should change the attached portal', () {
        fakeAsync(() async {
          ComponentFixture appFixture =
              await builder.createAsync(PortalTestApp);

          // Flush the async creation of the PortalTestApp.
          flushMicrotasks();

          // Set the selectedHost to be a ComponentPortal.
          PortalTestApp testAppComponent =
              appFixture.debugElement.componentInstance as PortalTestApp;

          // Detect changes initially so that the component's ViewChildren are resolved.
          appFixture.detectChanges();

          testAppComponent.selectedPortal = testAppComponent.piePortal;
          appFixture.detectChanges();

          // Flush the attachment of the Portal.
          flushMicrotasks();

          // Now that the portal is attached, change detection has to happen again in order
          // for the bindings to update.
          appFixture.detectChanges();

          // Expect that the content of the attached portal is present.
          var hostContainer = appFixture.nativeElement
              .querySelector('.portal-container') as Element;
          expect(hostContainer.text, contains('Pie'));

          testAppComponent.selectedPortal = new ComponentPortal(PizzaMsg);
          appFixture.detectChanges();

          flushMicrotasks();

          expect(hostContainer.text, contains('Pizza'));
        })();
      });
    });
    group('DomPortalHost', () {
      ComponentResolver componentLoader;
      ViewContainerRef aViewContainerRef;
      DivElement divElement;
      DomPortalHost host;

      ngSetUp((ComponentResolver dcl) {
        componentLoader = dcl;
        divElement = new DivElement();
        host = new DomPortalHost(divElement, componentLoader);
      });

      ngTest('should attach and detach a component portal', () {
        fakeAsync(() async {
          ComponentFixture fixture =
              await builder.createAsync(ArbitraryViewContainerRefComponent);
          aViewContainerRef =
              fixture.componentInstance.viewContainerRef as ViewContainerRef;

          // Flush the async creation of the PortalTestApp.
          flushMicrotasks();

          var portal = new ComponentPortal(PizzaMsg, aViewContainerRef);

          PizzaMsg componentInstance;

          componentInstance = (await portal.attach(host)).instance as PizzaMsg;

          flushMicrotasks();

          expect(componentInstance, new isInstanceOf<PizzaMsg>());
          expect(divElement.text, contains('Pizza'));

          await host.detach();
          flushMicrotasks();

          expect(divElement.innerHtml, isEmpty);
        })();
      });

      ngTest('should attach and detach a template portal', () {
        fakeAsync(() async {
          ComponentFixture appFixture =
              await builder.createAsync(PortalTestApp);
          flushMicrotasks();
          appFixture.detectChanges();
          await (appFixture.componentInstance as PortalTestApp).cakePortal.attach(host);
          flushMicrotasks();

          expect(divElement.text, contains('Cake'));
        })();
      }, skip: 'should fix this test.');

      ngTest('should attach and detach a template portal with a binding', () {
        fakeAsync(() async {
          ComponentFixture appFixture =
              await builder.createAsync(PortalTestApp);
          flushMicrotasks();
          PortalTestApp testAppComponent = appFixture.debugElement.componentInstance;
          appFixture.detectChanges();
          await testAppComponent.portalWithBinding.attach(host);
          appFixture.detectChanges();
          flushMicrotasks();
          // Now that the portal is attached, change detection has to happen again in order
          // for the bindings to update.
          appFixture.detectChanges();

          // Expect that the content of the attached portal is present.
          expect(divElement.text, contains('Banana'));

          // When updating the binding value.
          testAppComponent.fruit = 'Mango';
          appFixture.detectChanges();

          // Expect the new value to be reflected in the rendered output.
          expect(divElement.text, contains('Mango'));

          await host.detach();
          expect(divElement.innerHtml, isEmpty);
        })();
      }, skip: 'should fix this test.');

      ngTest('should change the attached portal', () {
        fakeAsync(() async {
          aViewContainerRef =
              (await builder.createAsync(ArbitraryViewContainerRefComponent))
                  .componentInstance
                  .viewContainerRef;
          flushMicrotasks();

          ComponentFixture appFixture =
              await builder.createAsync(PortalTestApp);
          flushMicrotasks();
          appFixture.detectChanges();
          appFixture.componentInstance.piePortal.attach(host);
          flushMicrotasks();

          expect(divElement.text, contains('Pie'));

          await host.detach();
          flushMicrotasks();

          await host.attach(new ComponentPortal(PizzaMsg, aViewContainerRef));
          flushMicrotasks();

          expect(divElement.text, contains('Pizza'));
        })();
      });
    });
  });
}

/// Simple component for testing ComponentPortal.
@Component(selector: 'pizza-msg', template: '<p>Pizza</p>')
class PizzaMsg {}

/// Simple component to grab an arbitrary ViewContainerRef
@Component(selector: 'some-placeholder', template: '<p>Hello</p>')
class ArbitraryViewContainerRefComponent {
  ViewContainerRef viewContainerRef;

  ArbitraryViewContainerRefComponent(this.viewContainerRef);
}

/// Test-bed component that contains a portal host and a couple of template portals.
@Component(
    selector: 'portal-test',
    template: '''
  <div class="portal-container">
    <template [portalHost]="selectedPortal"></template>
  </div>

  <template portal>Cake</template>

  <div *portal>Pie</div>

  <template portal> {{fruit}} </template>
  ''',
    directives: const [PortalHostDirective, TemplatePortalDirective])
class PortalTestApp {
  @ViewChildren(TemplatePortalDirective)
  QueryList<TemplatePortalDirective> portals;
  Portal<dynamic> selectedPortal;
  String fruit = 'Banana';

  Portal get cakePortal => portals.first;

  Portal get piePortal => portals.toList()[1];

  Portal get portalWithBinding => portals.toList()[2];
}
