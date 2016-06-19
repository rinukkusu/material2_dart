import "package:angular2/core.dart";
import "package:material2_dart/components/button/button.dart";
import "package:material2_dart/components/card/card.dart";

@Component(
    selector: "card-demo",
    templateUrl: "card_demo.html",
    styleUrls: const ["card_demo.css"],
    directives: const [MD_CARD_DIRECTIVES, MdButton])
class CardDemo {}
