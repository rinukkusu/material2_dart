import 'package:angular2/core.dart';
import 'package:material2_dart/core/line/line.dart';
export 'package:material2_dart/core/line/line.dart';

@Directive(selector: 'md-divider')
class MdListDivider {}

@Component(
    selector: 'md-list, md-nav-list',
    host: const {'role': 'list'},
    template: '<ng-content></ng-content>',
    styleUrls: const ['list.scss.css'],
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
  bool hasFocus = false;

  MdLineSetter _lineSetter;
  @ContentChildren(MdLine)
  QueryList<MdLine> lines;

  @override
  void ngAfterContentInit() {
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

  void handleFocus() {
    hasFocus = true;
  }

  void handleBlur() {
    hasFocus = false;
  }
}

const List MD_LIST_DIRECTIVES = const [
  MdList,
  MdListDivider,
  MdListItem,
  MdLine,
  MdListAvatar
];
