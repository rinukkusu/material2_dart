import "package:angular2/core.dart";
import "package:material2_dart/components/button/button.dart";
import "package:material2_dart/components/sidenav/sidenav.dart";

@Component(
    selector: "sidenav-demo",
    templateUrl: "sidenav_demo.html",
    styleUrls: const ["sidenav_demo.css"],
    directives: const [MD_SIDENAV_DIRECTIVES, MdButton])
class SidenavDemo {}
