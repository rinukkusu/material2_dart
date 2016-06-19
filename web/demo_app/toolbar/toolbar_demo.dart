import "package:angular2/core.dart";
import "package:material2_dart/components/icon/icon.dart";
import "package:material2_dart/components/toolbar/toolbar.dart";

@Component(
    selector: "toolbar-demo",
    templateUrl: "toolbar_demo.html",
    styleUrls: const ["toolbar_demo.css"],
    directives: const [MdToolbar, MdIcon])
class ToolbarDemo {}
