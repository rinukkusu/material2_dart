import 'dart:html';
import 'package:angular2/core.dart';
import "package:material2_dart/core/portal/portal_directives.dart";
import "tab_label.dart";
import "tab_content.dart";
import "tab_label_wrapper.dart";
import "ink_bar.dart";

export "tab_label.dart";
export "tab_content.dart";
export "tab_label_wrapper.dart";
export "ink_bar.dart";

/** Used to generate unique ID's for each tab component */
var nextId = 0;

/** A simple change event emitted on focus or selection changes. */
class MdTabChangeEvent {
  int index;
  MdTab tab;
}

@Directive(selector: "md-tab")
class MdTab {
  @ContentChild(MdTabLabel)
  MdTabLabel label;
  @ContentChild(MdTabContent)
  MdTabContent content;
}

/**
 * Material design tab-group component.  Supports basic tab pairs (label + content) and includes
 * animated ink-bar, keyboard navigation, and screen reader.
 * See: https://www.google.com/design/spec/components/tabs.html
 */
@Component(
    selector: "md-tab-group",
    templateUrl: "tab_group.html",
    styleUrls: const ["tab_group.scss.css"],
    directives: const [PortalHostDirective, MdTabLabelWrapper, MdInkBar])
class MdTabGroup implements AfterViewChecked {
  NgZone _zone;

  /** @internal */
  @ContentChildren(MdTab)
  QueryList<MdTab> tabs;
  @ViewChildren(MdTabLabelWrapper)
  QueryList<MdTabLabelWrapper> labelWrappers;
  @ViewChildren(MdInkBar)
  QueryList<MdInkBar> inkBar;
  bool _isInitialized = false;
  int _selectedIndex = 0;

  @Input()
  set selectedIndex(int value) {
    _selectedIndex = value;
    if (_isInitialized) {
      _onSelectChange.emit(_createChangeEvent(value));
    }
  }

  int get selectedIndex => _selectedIndex;

  EventEmitter<MdTabChangeEvent> _onFocusChange =
      new EventEmitter<MdTabChangeEvent>();

  @Output("focusChange")
  Stream<MdTabChangeEvent> get focusChange => _onFocusChange;

  EventEmitter<MdTabChangeEvent> _onSelectChange =
      new EventEmitter<MdTabChangeEvent>();

  @Output("selectChange")
  Stream<MdTabChangeEvent> get selectChange => _onSelectChange;

  int _focusIndex = 0;
  int _groupId;

  MdTabGroup(this._zone) {
    _groupId = nextId++;
  }

  /**
   * Waits one frame for the view to update, then upates the ink bar
   * Note: This must be run outside of the zone or it will create an infinite change detection loop
   * TODO: internal
   */
  void ngAfterViewChecked() {
    _zone.runOutsideAngular(() {
      window.requestAnimationFrame((_) {
        _updateInkBar();
      });
    });
    _isInitialized = true;
  }

  /** Tells the ink-bar to align itself to the current label wrapper */
  void _updateInkBar() {
    inkBar.toList()[0].alignToElement(_currentLabelWrapper);
  }

  /**
   * Reference to the current label wrapper; defaults to null for initial render before the
   * ViewChildren references are ready.
   */
  Element get _currentLabelWrapper {
    return labelWrappers != null && labelWrappers.isNotEmpty
        ? labelWrappers.toList()[selectedIndex].elementRef.nativeElement
        : null;
  }

  /** Tracks which element has focus; used for keyboard navigation */
  int get focusIndex => _focusIndex;

  /** When the focus index is set, we must manually send focus to the correct label */
  set focusIndex(int value) {
    _focusIndex = value;
    if (_isInitialized) {
      _onFocusChange.emit(_createChangeEvent(value));
    }
    if (labelWrappers != null && labelWrappers.isNotEmpty) {
      labelWrappers.toList()[value].focus();
    }
  }

  MdTabChangeEvent _createChangeEvent(int index) {
    final event = new MdTabChangeEvent();
    event.index = index;
    if (tabs != null && tabs.isNotEmpty) {
      event.tab = tabs.toList()[index];
    }
    return event;
  }

  /**
   * Returns a unique id for each tab label element
   * @internal
   */
  String getTabLabelId(int i) => 'md-tab-label-$_groupId-$i';

  /**
   * Returns a unique id for each tab content element
   * @internal
   */
  String getTabContentId(int i) => 'md-tab-content-$_groupId-$i';

  /** Increment the focus index by 1; prevent going over the number of tabs */
  void focusNextTab() {
    if (labelWrappers != null && focusIndex < labelWrappers.length - 1) {
      focusIndex++;
    }
  }

  /** Decrement the focus index by 1; prevent going below 0 */
  void focusPreviousTab() {
    if (focusIndex > 0) focusIndex--;
  }
}

const MD_TABS_DIRECTIVES = const [MdTabGroup, MdTabLabel, MdTabContent, MdTab];
