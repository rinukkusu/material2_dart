import "package:angular2/core.dart";

import "package:material2_dart/components/button_toggle/button_toggle.dart";
import "package:material2_dart/core/coordination/unique_selection_dispatcher.dart";
import "package:material2_dart/components/icon/icon.dart";

@Component(
    selector: "button-toggle-demo",
    templateUrl: "button_toggle_demo.html",
    providers: const [MdUniqueSelectionDispatcher],
    directives: const [MD_BUTTON_TOGGLE_DIRECTIVES, MdIcon])
class ButtonToggleDemo {
  String favoritePie = 'Apple';
  List<String> pieOptions = [
    'Apple',
    'Cherry',
    'Pecan',
    'Lemon',
  ];
}
