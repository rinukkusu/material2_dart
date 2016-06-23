import "package:angular2/core.dart";
import "package:material2_dart/components/input/input.dart";
import "package:material2_dart/components/button/button.dart";
import "package:material2_dart/components/card/card.dart";
import "package:material2_dart/components/checkbox/checkbox.dart";
import "package:material2_dart/components/icon/icon.dart";
import "package:material2_dart/components/toolbar/toolbar.dart";

var max = 5;

@Component(
    selector: "input-demo",
    templateUrl: "input_demo.html",
    styleUrls: const [
      "input_demo.scss.css"
    ],
    directives: const [
      MdCard,
      MdCheckbox,
      MdButton,
      MdIcon,
      MdToolbar,
      MD_INPUT_DIRECTIVES
    ])
class InputDemo {
  bool dividerColor = false;
  bool requiredField = false;
  bool floatingLabel = false;
  String name;
  List<Map<String, int>> items = [
    {"value": 10},
    {"value": 20},
    {"value": 30},
    {"value": 40},
    {"value": 50}
  ];

  addABunch(num n) {
    for (var x = 0; x < n; x++) {
      items.add({'value': ++max});
    }
  }
}
