import "package:angular2/core.dart";
import "package:material2_dart/components/grid_list/grid_list.dart";
import "package:material2_dart/components/button/button.dart";
import "package:material2_dart/components/card/card.dart";
import "package:material2_dart/components/icon/icon.dart";

@Component(
    selector: "grid-list-demo",
    templateUrl: "grid_list_demo.html",
    styleUrls: const [
      "grid_list_demo.scss.css"
    ],
    directives: const [
      MD_GRID_LIST_DIRECTIVES,
      MdButton,
      MD_CARD_DIRECTIVES,
      MdIcon
    ],
    providers: const [
      MdIconRegistry
    ])
class GridListDemo {
  List<Map> tiles = [
    {"text": "One", "cols": 3, "rows": 1, "color": "lightblue"},
    {"text": "Two", "cols": 1, "rows": 2, "color": "lightgreen"},
    {"text": "Three", "cols": 1, "rows": 1, "color": "lightpink"},
    {"text": "Four", "cols": 2, "rows": 1, "color": "#DDBDF1"}
  ];
  List<Map<String, String>> dogs = [
    {"name": "Porter", "human": "Kara"},
    {"name": "Mal", "human": "Jeremy"},
    {"name": "Koby", "human": "Igor"},
    {"name": "Razzle", "human": "Ward"},
    {"name": "Molly", "human": "Rob"},
    {"name": "Husi", "human": "Matias"}
  ];
  num fixedCols = 4;
  num fixedRowHeight = 100;
  num ratioGutter = 1;
  String fitListHeight = "400px";
  String ratio = "4:1";
  String basicRowHeight = '100px';

  void addTileCols() {
    tiles[2]['cols']++;
  }
}
