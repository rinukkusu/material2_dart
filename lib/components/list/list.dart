import 'package:angular2/core.dart';

@Component(
    selector: 'md-list, md-nav-list',
    host: const {'role': 'list'},
    template: '<ng-content></ng-content>',
    styleUrls: const ['list.scss.css'],
    encapsulation: ViewEncapsulation.None)
class MdList {}

/* Need directive for a ContentChildren query in list-item */
@Directive(selector: '[md-line]')
class MdLine {}

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
  @ContentChildren(MdLine)
  QueryList<MdLine> lines;

  /** @internal */
  bool hasFocus = false;

  /** TODO: internal */
  ngAfterContentInit() {
    _setLineClass(lines.length);

    lines.changes.listen((_) {
      _setLineClass(lines.length);
    });
  }

  @ContentChild(MdListAvatar)
  set hasAvatar(MdListAvatar avatar) {
    _setClass('md-list-avatar', avatar != null);
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

  void _setLineClass(int count) {
    _resetClasses();
    if (count == 2 || count == 3) {
      _setClass('md-$count-line', true);
    }
  }

  void _resetClasses() {
    _setClass('md-2-line', false);
    _setClass('md-3-line', false);
  }

  void _setClass(String className, bool bool) {
    _renderer.setElementClass(_elementRef.nativeElement, className, bool);
  }
}

const MD_LIST_DIRECTIVES = const [MdList, MdListItem, MdLine, MdListAvatar];
