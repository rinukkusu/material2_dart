import "package:angular2/core.dart";
import "package:material2_dart/components/icon/icon.dart";

@Component(
    selector: "md-icon-demo",
    templateUrl: "icon_demo.html",
    styleUrls: const ["icon_demo.scss.css"],
    directives: const [MdIcon],
    viewProviders: const [MdIconRegistry],
    encapsulation: ViewEncapsulation.None)
class IconDemo {
  IconDemo(MdIconRegistry mdIconRegistry) {
    mdIconRegistry
        .addSvgIcon("thumb-up", "/demo_app/icon/assets/thumbup_icon.svg")
        .addSvgIconSetInNamespace(
            "core", "/demo_app/icon/assets/core_icon_set.svg")
        .registerFontClassAlias("fontawesome", "fa");
  }
}
