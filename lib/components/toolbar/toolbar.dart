import 'package:angular2/core.dart';

@Component(
    selector: 'md-toolbar',
    templateUrl: 'toolbar.html',
    styleUrls: const ['toolbar.scss.css'],
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdToolbar {
  @Input()
  String get color => _color;

  void set color(String value) {
    _updateColor(value);
  }

  String _color;
  ElementRef _elementRef;
  Renderer _renderer;

  MdToolbar(this._elementRef, this._renderer);

  _updateColor(String newColor) {
    _setElementColor(_color, false);
    _setElementColor(newColor, true);
    _color = newColor;
  }

  _setElementColor(String color, bool isAdd) {
    if (color != null && color.isNotEmpty) {
      _renderer.setElementClass(_elementRef.nativeElement, 'md-$color', isAdd);
    }
  }
}

const MD_TOOLBAR_DIRECTIVES = const [MdToolbar];
