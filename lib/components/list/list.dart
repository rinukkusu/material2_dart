import 'package:angular2/core.dart';
import 'package:material2_dart/core/line/line.dart';

@Component(
    selector: 'md-list, md-nav-list',
    host: const {'role': 'list'},
    template: '<ng-content></ng-content>',
    styleUrls: const ['list.css'],
    encapsulation: ViewEncapsulation.None)
class MdList {}

/* Need directive for a ContentChild query in list-item */
@Directive(selector: '[md-list-avatar]')
class MdListAvatar {}

@Component(
    selector: 'md-list-item, a[md-list-item]',
    host: const {
      'role': 'listitem',
      '(focus)': 'handleFocus()',
      '(blur)': 'handleBlur()',
    },
    templateUrl: 'list_item.html',
    encapsulation: ViewEncapsulation.None)
class MdListItem implements AfterContentInit {
  /** @internal */
  bool hasFocus = false;

  MdLineSetter _lineSetter;
  @ContentChildren(MdLine)
  QueryList<MdLine> lines;

  /** TODO: internal */
  ngAfterContentInit() {
    _lineSetter = new MdLineSetter(lines, _renderer, _elementRef);
  }

  @ContentChild(MdListAvatar)
  set hasAvatar(MdListAvatar avatar) {
    _renderer.setElementClass(
        _elementRef.nativeElement, 'md-list-avatar', avatar != null);
  }

  Renderer _renderer;
  ElementRef _elementRef;

  MdListItem(this._renderer, this._elementRef);

  /** @internal */
  void handleFocus() {
    hasFocus = true;
  }

  /** @internal */
  void handleBlur() {
    hasFocus = false;
  }
}

const MD_LIST_DIRECTIVES = const [MdList, MdListItem, MdLine, MdListAvatar];
