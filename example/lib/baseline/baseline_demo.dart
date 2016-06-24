import "package:angular2/core.dart";
import "package:material2_dart/components/input/input.dart";
import "package:material2_dart/components/button/button.dart";
import "package:material2_dart/components/card/card.dart";
import "package:material2_dart/components/checkbox/checkbox.dart";
import "package:material2_dart/components/radio/radio.dart";
import "package:material2_dart/components/icon/icon.dart";
import "package:material2_dart/components/toolbar/toolbar.dart";
import "package:material2_dart/core/coordination/unique_selection_dispatcher.dart";

@Component(
    selector: "baseline-demo",
    templateUrl: "baseline_demo.html",
    styleUrls: const [
      "baseline_demo.scss.css"
    ],
    providers: const [
      MdUniqueSelectionDispatcher
    ],
    directives: const [
      MD_BUTTON_DIRECTIVES,
      MD_CARD_DIRECTIVES,
      MD_CHECKBOX_DIRECTIVES,
      MD_RADIO_DIRECTIVES,
      MD_INPUT_DIRECTIVES,
      MdIcon,
      MdToolbar
    ])
class BaselineDemo {
  String name;
}
