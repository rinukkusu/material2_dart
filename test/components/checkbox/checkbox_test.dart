import 'package:angular2/core.dart';

//import 'package:angular2/platform/browser.dart';
import 'package:angular2_testing/angular2_testing.dart';
@TestOn('browser')
import 'package:test/test.dart';

void main() {
//  TestComponentBuilder builder;

  initAngularTests();

  setUpProviders(() {
    return const [
      const Provider(TestComponentBuilder, useClass: TestComponentBuilder)
    ];
  });

//  ngSetUp((TestComponentBuilder tcb) {
//    builder = tcb;
//  });

  ngTest('checkbox test', () async {}, skip: 'Implement later.');
}
