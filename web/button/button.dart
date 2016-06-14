import 'package:angular2/core.dart';
import 'package:material2_dart/components.dart';

@Component(
  selector: 'button-demo',
  templateUrl: 'button.html',
  styleUrls: const ['button.css'],
  directives: const [MD_DIRECTIVES])
class ButtonDemo {
  bool isDisabled = false;
  num clickCounter = 0;
}
