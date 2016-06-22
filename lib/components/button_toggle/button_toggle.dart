import 'dart:html';
import 'dart:async';
import "package:angular2/core.dart";
import "package:material2_dart/core/coordination/unique_selection_dispatcher.dart";
import "package:material2_dart/core/annotations/field_value.dart";

var _uniqueIdCounter = 0;

/** A simple change event emitted by either MdButtonToggle or MdButtonToggleGroup. */
class MdButtonToggleChange {
  MdButtonToggle source;
  dynamic value;
}

/** Exclusive selection button toggle group that behaves like a radio-button group. */
@Directive(
    selector: "md-button-toggle-group:not([multiple])",
    host: const {"role": "radiogroup"})
class MdButtonToggleGroup {
  /** The value for the button toggle group. Should match currently selected button toggle. */
  dynamic _value;

  /** The HTML name attribute applied to toggles in this group. */
  String _name = 'md-radio-group-${_uniqueIdCounter++}';

  /** Disables all toggles in the group. */
  bool _disabled;

  /** The currently selected button toggle, should match the value. */
  MdButtonToggle _selected;

  /** Event emitted when the group's value changes. */
  EventEmitter<MdButtonToggleChange> _change =
      new EventEmitter<MdButtonToggleChange>();

  @Output()
  Stream<MdButtonToggleChange> get change => _change;

  /** Child button toggle buttons. */
  @ContentChildren(MdButtonToggle)
  QueryList<MdButtonToggle> _buttonToggles;

  String get name => _name;

  @Input()
  set name(String value) {
    _name = value;
    _updateButtonToggleNames();
  }

  bool get disabled => _disabled;

  @Input()
  set disabled(dynamic v) {
    v = booleanFieldValue(v);
    _disabled = (v != null && !identical(v, false)) ? true : null;
  }

  dynamic get value => _value;

  @Input()
  set value(dynamic newValue) {
    if (_value != newValue) {
      _value = newValue;
      _updateSelectedButtonToggleFromValue();
      _emitChangeEvent();
    }
  }

  get selected => _selected;

  @Input()
  set selected(MdButtonToggle selected) {
    _selected = selected;
    value = selected != null ? selected.value : null;
    if (selected != null && !selected.checked) {
      selected.checked = true;
    }
  }

  void _updateButtonToggleNames() {
    Iterable bt = _buttonToggles == null ? [] : _buttonToggles;
    bt.forEach((toggle) {
      toggle.name = _name;
    });
  }

  // TODO: Refactor into shared code with radio.
  void _updateSelectedButtonToggleFromValue() {
    var isAlreadySelected = _selected != null && _selected.value == _value;
    if (_buttonToggles != null && !isAlreadySelected) {
      var matchingButtonToggle = _buttonToggles.firstWhere(
          (buttonToggle) => buttonToggle.value == _value,
          orElse: () => null);
      if (matchingButtonToggle != null) {
        selected = matchingButtonToggle;
      } else if (value == null) {
        selected = null;
        _buttonToggles.forEach((buttonToggle) {
          buttonToggle.checked = false;
        });
      }
    }
  }

  /** Dispatch change event with current selection and group value. */
  void _emitChangeEvent() {
    var event = new MdButtonToggleChange();
    event.source = _selected;
    event.value = _value;
    _change.emit(event);
  }
}

/** Multiple selection button-toggle group. */
@Directive(selector: "md-button-toggle-group[multiple]")
class MdButtonToggleGroupMultiple {
  /** Disables all toggles in the group. */
  bool _disabled = false;

  bool get disabled => _disabled;

  @Input()
  set disabled(value) {
    _disabled = (value != null && !identical(value, false)) ? true : null;
  }
}

//enum ToggleType { checkbox, radio }

@Component(
    selector: "md-button-toggle",
    templateUrl: "button_toggle.html",
    styleUrls: const ["button_toggle.css"],
    encapsulation: ViewEncapsulation.None)
class MdButtonToggle implements OnInit {
  MdUniqueSelectionDispatcher buttonToggleDispatcher;

  /** Whether or not this button toggle is checked. */
  bool _checked = false;

  /**
   * Type of the button toggle. Either 'radio' or 'checkbox'.
   * @internal
   */
  String type;

  /** The unique ID for this button toggle. */
  @HostBinding()
  @Input()
  String id;

  /** HTML's 'name' attribute used to group radios for unique selection. */
  @Input()
  String name;

  /** Whether or not this button toggle is disabled. */
  bool _disabled = false;

  /** Value assigned to this button toggle. */
  dynamic _value = null;

  /** Whether or not the button toggle is a single selection. */
  bool _isSingleSelector = false;

  /** The parent button toggle group (exclusive selection). Optional. */
  MdButtonToggleGroup buttonToggleGroup;

  /** The parent button toggle group (multiple selection). Optional. */
  MdButtonToggleGroupMultiple buttonToggleGroupMultiple;

  /** Event emitted when the group value changes. */
  EventEmitter<MdButtonToggleChange> _change =
      new EventEmitter<MdButtonToggleChange>();

  @Output()
  Stream<MdButtonToggleChange> get change => _change;

  MdButtonToggle(
      @Optional() MdButtonToggleGroup toggleGroup,
      @Optional() MdButtonToggleGroupMultiple toggleGroupMultiple,
      buttonToggleDispatcher) {
    buttonToggleGroup = toggleGroup;
    buttonToggleGroupMultiple = toggleGroupMultiple;
    if (buttonToggleGroup != null) {
      buttonToggleDispatcher.listen((String id, String name) {
        if (id != id && name == name) {
          checked = false;
        }
      });
      type = 'radio';
//      type = ToggleType.radio;
      name = buttonToggleGroup.name;
      _isSingleSelector = true;
    } else {
      // Even if there is no group at all, treat the button toggle as a checkbox so it can be
      // toggled on or off.
      type = 'checkbox';
//      type = ToggleType.checkbox;
      _isSingleSelector = false;
    }
  }

  /** @internal */
  ngOnInit() {
    if (id == null) {
      id = 'md-button-toggle-${_uniqueIdCounter++}';
    }
    if (buttonToggleGroup != null && _value == buttonToggleGroup.value) {
      _checked = true;
    }
  }

  String get inputId => '$id-input';

  @HostBinding("class.md-button-toggle-checked")
  bool get checked => _checked;

  @Input()
  set checked(bool newCheckedState) {
    if (_isSingleSelector) {
      if (newCheckedState) {
        // Notify all button toggles with the same name (in the same group) to un-check.
        buttonToggleDispatcher.notify(id, name);
      }
      if (newCheckedState != _checked) {
        _emitChangeEvent();
      }
    }
    _checked = newCheckedState;
    if (newCheckedState &&
        _isSingleSelector &&
        buttonToggleGroup.value != value) {
      buttonToggleGroup.selected = this;
    }
  }

  /** MdButtonToggleGroup reads this to assign its own value. */
  dynamic get value => _value;

  @Input()
  set value(dynamic value) {
    if (_value != value) {
      if (buttonToggleGroup != null && checked) {
        buttonToggleGroup.value = value;
      }
      _value = value;
    }
  }

  /** Dispatch change event with current value. */
  void _emitChangeEvent() {
    var event = new MdButtonToggleChange();
    event.source = this;
    event.value = _value;
    _change.emit(event);
  }

  @HostBinding("class.md-button-toggle-disabled")
  bool get disabled {
    return _disabled ||
        (buttonToggleGroup != null && buttonToggleGroup.disabled) ||
        (buttonToggleGroupMultiple != null &&
            buttonToggleGroupMultiple.disabled);
  }

  @Input()
  set disabled(bool value) {
    _disabled = (value != null && !identical(value, false)) ? true : null;
  }

  /** Toggle the state of the current button toggle. */
  void _toggle() {
    checked = !checked;
  }

  /**
   * Checks the button toggle due to an interaction with the underlying native input.
   * @internal
   */
  onInputChange(Event event) {
    event.stopPropagation();
    if (_isSingleSelector) {
      // Propagate the change one-way via the group, which will in turn mark this
      // button toggle as checked.
      checked = true;
      buttonToggleGroup.selected = this;
    } else {
      _toggle();
    }
  }
}

const MD_BUTTON_TOGGLE_DIRECTIVES = const [
  MdButtonToggleGroup,
  MdButtonToggleGroupMultiple,
  MdButtonToggle
];
