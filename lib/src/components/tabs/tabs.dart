import 'dart:html';
import 'dart:async';
import 'package:angular2/angular2.dart';
import "../../core/core.dart";
import "tab_label.dart";
import "tab_label_wrapper.dart";
import 'tab_nav_bar/tab_nav_bar.dart';
import "ink_bar.dart";

export "tab_label.dart";
export "tab_label_wrapper.dart";
export "ink_bar.dart";
export 'tab_nav_bar/tab_nav_bar.dart';

/// Used to generate unique ID's for each tab component.
int _nextId = 0;

/// A simple change event emitted on focus or selection changes.
class MdTabChangeEvent {
  int index;
  MdTab tab;
}

@Component(selector: "md-tab", templateUrl: 'tab.html')
class MdTab implements OnInit {
  /// Content for the tab label given by <template md-tab-label>.
  @ContentChild(MdTabLabel)
  MdTabLabel templateLabel;

  /// Template inside the MdTab view that contains an <ng-content>.
  @ViewChild(TemplateRef)
  TemplateRef templateRef;

  /// The plain text label for the tab, used when there is no template label.
  @Input('label')
  String textLabel = '';

  TemplatePortal _contentPortal;
  ViewContainerRef _viewContainerRef;
  MdTab(this._viewContainerRef);

  @override
  void ngOnInit() {
    _contentPortal = new TemplatePortal(templateRef, _viewContainerRef);
  }

  bool _disabled = false;
  @Input()
  set disabled(bool value) {
    _disabled = coerceBooleanProperty(value);
  }

  bool get disabled => _disabled;

  TemplatePortal get content => _contentPortal;
}

/// Material design tab-group component.
/// Supports basic tab pairs (label + content) and includes
/// animated ink-bar, keyboard navigation, and screen reader.
/// See: https://www.google.com/design/spec/components/tabs.html
@Component(
    selector: "md-tab-group",
    templateUrl: "tab_group.html",
    styleUrls: const ["tab_group.scss.css"],
    directives: const [PortalHostDirective, MdTabLabelWrapper, MdInkBar])
class MdTabGroup implements AfterViewChecked {
  NgZone _zone;
  @ContentChildren(MdTab)
  QueryList<MdTab> tabs;
  @ViewChildren(MdTabLabelWrapper)
  QueryList<MdTabLabelWrapper> labelWrappers;
  @ViewChildren(MdInkBar)
  QueryList<MdInkBar> inkBar;

  @ViewChild('tabBodyWrapper')
  ElementRef _tabBodyWrapper;

  bool _isInitialized = false;

  /** Snapshot of the height of the tab body wrapper before another tab is activated. */
  num _tabBodyWrapperHeight = 0;

  /** Whether the tab group should grow to the size of the active tab */
  bool _dynamicHeight = false;
  @Input('md-dynamic-height')
  set dynamicHeight(bool value) {
    this._dynamicHeight = coerceBooleanProperty(value);
  }

  /** The index of the active tab. */
  int _selectedIndex = 0;

  @Input()
  set selectedIndex(int value) {
    _tabBodyWrapperHeight = _tabBodyWrapper.nativeElement.clientHeight;

    if (value != _selectedIndex && isValidIndex(value)) {
      _selectedIndex = value;
      if (_isInitialized) {
        _onSelectChange.emit(_createChangeEvent(value));
      }
    }
  }

  int get selectedIndex => _selectedIndex;

  /// Determines if an index is valid.
  /// If the tabs are not ready yet, we assume that the user is
  /// providing a valid index and return true.
  bool isValidIndex(int index) {
    if (tabs != null && tabs.isNotEmpty) {
      final tab = tabs.toList()[index];
      return tab != null && !tab.disabled;
    } else {
      return true;
    }
  }

  /// Output to enable support for two-way binding on `selectedIndex`.
  @Output('selectedIndexChange')
  Stream<int> get selectedIndexChange =>
      selectChange.map((MdTabChangeEvent event) => event.index);

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
    _groupId = _nextId++;
  }

  /// Waits one frame for the view to update, then updates the ink bar
  /// Note: This must be run outside of the zone
  /// or it will create an infinite change detection loop
  @override
  void ngAfterViewChecked() {
    _zone.runOutsideAngular(() {
      window.requestAnimationFrame((_) {
        _updateInkBar();
      });
    });
    _isInitialized = true;
  }

  /// Tells the ink-bar to align itself to the current label wrapper.
  void _updateInkBar() {
    inkBar.toList().first.alignToElement(_currentLabelWrapper);
  }

  /// Reference to the current label wrapper;
  /// defaults to null for initial render before the
  /// ViewChildren references are ready.
  Element get _currentLabelWrapper {
    return labelWrappers != null && labelWrappers.isNotEmpty
        ? labelWrappers.toList()[selectedIndex].elementRef.nativeElement
            as Element
        : null;
  }

  /// Tracks which element has focus; used for keyboard navigation.
  int get focusIndex => _focusIndex;

  /// When the focus index is set, we must manually send focus to the correct label.
  set focusIndex(int value) {
    if (isValidIndex(value)) {
      _focusIndex = value;

      if (_isInitialized) {
        _onFocusChange.add(_createChangeEvent(value));
      }

      if (labelWrappers != null && labelWrappers.isNotEmpty) {
        labelWrappers.toList()[value].focus();
      }
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

  /// Returns a unique id for each tab label element.
  String getTabLabelId(int i) => 'md-tab-label-$_groupId-$i';

  /// Returns a unique id for each tab content element.
  String getTabContentId(int i) => 'md-tab-content-$_groupId-$i';


  /**
   * Sets the height of the body wrapper to the height of the activating tab if dynamic
   * height property is true.
   */
  void setTabBodyWrapperHeight(num tabHeight) {
    if (!_dynamicHeight) { return; }

    _tabBodyWrapper.nativeElement.style.height = '${_tabBodyWrapperHeight}px';

    // This conditional forces the browser to paint the height so that
    // the animation to the new height can have an origin.
    if (_tabBodyWrapper.nativeElement.offsetHeight) {
      _tabBodyWrapper.nativeElement.style.height = '${tabHeight}px';
    }
  }

  /** Removes the height of the tab body wrapper. */
  void removeTabBodyWrapperHeight() {
    _tabBodyWrapper.nativeElement.style.height = '';
  }

  void handleKeydown(KeyboardEvent event) {
    switch (event.keyCode) {
      case KeyCode.RIGHT:
        focusNextTab();
        break;
      case KeyCode.LEFT:
        focusPreviousTab();
        break;
      case KeyCode.ENTER:
        selectedIndex = focusIndex;
        break;
    }
  }

  /// Moves the focus left or right depending on the offset provided.
  /// Valid offsets are 1 and -1.
  void moveFocus(int offset) {
    if (labelWrappers != null && labelWrappers.isNotEmpty) {
      final List<MdTab> tabs = this.tabs.toList();
      for (var i = focusIndex + offset;
          i < tabs.length && i >= 0;
          i += offset) {
        if (isValidIndex(i)) {
          focusIndex = i;
          return;
        }
      }
    }
  }

  /// Increment the focus index by 1; prevent going over the number of tabs.
  void focusNextTab() {
    moveFocus(1);
  }

  /// Decrement the focus index by 1; prevent going below 0.
  void focusPreviousTab() {
    moveFocus(-1);
  }
}

class MdTabBodyActiveState implements String {
  static const String LEFT = 'left';
  static const String CENTER = 'center';
  static const String RIGHT = 'right';
}

@Component(
  selector: 'md-tab-body',
  templateUrl: 'tab-body.html',
  /*animations: [
    trigger('translateTab', [
      state('left', style({transform: 'translate3d(-100%, 0, 0)'})),
      state('center', style({transform: 'translate3d(0, 0, 0)'})),
      state('right', style({transform: 'translate3d(100%, 0, 0)'})),
      transition('* => *', animate('500ms cubic-bezier(0.35, 0, 0.25, 1)')),
    ])
  ]*/
)
class MdTabBody implements OnInit, AfterViewInit {
  /** The portal host inside of this container into which the tab body content will be loaded. */
  @ViewChild(PortalHostDirective)
  PortalHostDirective _portalHost;

  @ViewChild('bodyContainer')
  ElementRef _bodyContainer;

  /** Event emitted when the tab begins to animate towards the center as the active tab. */
  @Output()
  Stream<num> onTabBodyCentering = _onTabBodyCentering.stream;
  StreamController<num> _onTabBodyCentering = new StreamController();

  /** Event emitted when the tab completes its animation towards the center. */
  @Output()
  Stream<dynamic> onTabBodyCentered = _onTabBodyCentered.stream;
  StreamController<num> _onTabBodyCentered = new StreamController();

  /** The tab body content to display. */
  @Input('md-tab-body-content')
  TemplatePortal content;

  /** The shifted index position of the tab body, where zero represents the active center tab. */
  MdTabBodyActiveState _position;
  @Input('md-tab-body-position')
  set position(num v) {
    MdTabBodyActiveState oldPosition = _position;
    if (v < 0) {
      _position = /*getLayoutDirection() == 'ltr' ?*/ MdTabBodyActiveState.LEFT /*: MdTabBodyActiveState.RIGHT*/;
    } else if (v > 0) {
      _position = /*getLayoutDirection() == 'ltr' ?*/ MdTabBodyActiveState.RIGHT /*: MdTabBodyActiveState.LEFT*/;
    } else {
      _position = MdTabBodyActiveState.CENTER;
    }

    MdTabBodyActiveState localPosition = _position;

    if (_position == MdTabBodyActiveState.CENTER && !_portalHost.hasAttached() && content != null) {
      _portalHost.attach(content);
    }

    // Emulate animations framework from Angular 2 TS
    new Timer(new Duration(milliseconds: 1), () => onTranslateTabStarted(oldPosition, localPosition));
    new Timer(new Duration(milliseconds: 500), () => onTranslateTabComplete(localPosition));
  }

  ElementRef _elementRef;
  Dir _dir;
  MdTabBody(ElementRef _elementRef, @Optional() Dir _dir) {}

  ngOnInit() {
    if (_position == MdTabBodyActiveState.CENTER && !_portalHost.hasAttached()) {
      _portalHost.attach(content);
    }
  }

  ngOnAfterViewInit() {
    _bodyContainer.nativeElement.style.transition = '500ms cubic-bezier(0.35, 0, 0.25, 1)';
  }

  onTranslateTabStarted(MdTabBodyActiveState fromState, MdTabBodyActiveState toState) {
    switch(toState) {
      case MdTabBodyActiveState.LEFT:
        _bodyContainer.nativeElement.style.transform = 'translate3d(-100%, 0, 0)';
        break;
      case MdTabBodyActiveState.CENTER:
        _bodyContainer.nativeElement.style.transform = 'translate3d(0, 0, 0)';
        break;
      case MdTabBodyActiveState.RIGHT:
        _bodyContainer.nativeElement.style.transform = 'translate3d(100%, 0, 0)';
        break;
    }

    if (fromState != null && toState == MdTabBodyActiveState.CENTER) {
      _onTabBodyCentering.add(_elementRef.nativeElement.clientHeight);
    }
  }

  onTranslateTabComplete(MdTabBodyActiveState toState) {
    if ((toState == MdTabBodyActiveState.LEFT || toState == MdTabBodyActiveState.RIGHT)
        && _position != MdTabBodyActiveState.CENTER) {
      // If the end state is that the tab is not centered, then detach the content.
      _portalHost.detach();
    }

    if ((toState == MdTabBodyActiveState.CENTER) &&
      _position == MdTabBodyActiveState.CENTER) {
      _onTabBodyCentered.add(null);
    }
  }

  /** The text direction of the containing app. */
  /*LayoutDirection getLayoutDirection() {
    return _dir && _dir.value === 'rtl' ? 'rtl' : 'ltr';
  }*/
}

const List MD_TABS_DIRECTIVES = const [
  MdTabGroup,
  MdTabLabel,
  MdTab,
  MdTabNavBar,
  MdTabLink,
  MdTabBody,
];

