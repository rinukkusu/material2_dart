import "package:angular2/core.dart";
import "package:material2_dart/components/button/button.dart";
import "package:material2_dart/components/progress_circle/progress_circle.dart";

@Component(
    selector: "progress-circle-demo",
    templateUrl: "progress_circle_demo.html",
    styleUrls: const ["progress_circle_demo.scss.css"],
    directives: const [MdProgressCircle, MdSpinner, MdButton])
class ProgressCircleDemo {
  num progressValue = 40;

  step(num val) {
    progressValue += val;
  }
}
