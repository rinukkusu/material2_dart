import 'dart:html';
import "package:angular2/core.dart";
import "package:angular2/common.dart";
import "package:material2_dart/core/annotations/field_value.dart";
import "package:material2_dart/core/coordination/unique_selection_dispatcher.dart";

// Re-exports.
export "package:material2_dart/core/coordination/unique_selection_dispatcher.dart";

/**
 * Provider Expression that allows md-radio-group to register as a ControlValueAccessor. This
 * allows it to support [(ngModel)] and ngControl.
 */
const Provider MD_RADIO_GROUP_CONTROL_VALUE_ACCESSOR =
    const Provider(NG_VALUE_ACCESSOR, useExisting: MdRadioGroup, multi: true);

// TODO(mtlin):
// Ink ripple is currently placeholder.
// Determine motion spec for button transitions.
// Design review.
// RTL
// Support forms API.

// Use ChangeDetectionStrategy.OnPush
var _uniqueIdCounter = 0;

/** A simple change event emitted by either MdRadioButton or MdRadioGroup. */
class MdRadioChange {
  MdRadioButton source;
  dynamic value;
}

@Directive(
    selector: "md-radio-group",
    providers: const [MD_RADIO_GROUP_CONTROL_VALUE_ACCESSOR],
    host: const {"role": "radiogroup"})
class MdRadioGroup implements AfterContentInit, ControlValueAccessor<dynamic> {
  /**
   * Selected value for group. Should equal the value of the selected radio button if there *is*
   * a corresponding radio button with a matching value. If there is *not* such a corresponding
   * radio button, this value persists to be applied in case a new radio button is added with a
   * matching value.
   */
  dynamic _value;

  /** The HTML name attribute applied to radio buttons in this group. */
  String _name = 'md-radio-group-${_uniqueIdCounter++}';

  /** Disables all individual radio buttons assigned to this group. */
  bool _disabled = false;

  /** The currently selected radio button. Should match value. */
  MdRadioButton _selected;

  /** Whether the `value` has been set to its initial value. */
  bool _isInitialized = false;

  /** The method to be called in order to update ngModel */
  dynamic _controlValueAccessorChangeFn = (dynamic value) {};

  /** onTouch function registered via registerOnTouch (ControlValueAccessor). */
  dynamic onTouched = () {};

  /** Event emitted when the group value changes. */
  @Output()
  EventEmitter<MdRadioChange> change = new EventEmitter<MdRadioChange>();

  /** Child radio buttons. */
  @ContentChildren(MdRadioButton)
  QueryList<MdRadioButton> radios;

  String get name => _name;

  @Input()
  set name(String value) {
    _name = value;
    _updateRadioButtonNames();
  }

  // start | end
  @Input()
  String align;

  bool get disabled => _disabled;

  @Input()
  set disabled(dynamic value) {
    // The presence of *any* disabled value makes the component disabled, *except* for false.
    _disabled = booleanFieldValue(value);
  }

  dynamic get value => _value;

  @Input()
  set value(dynamic newValue) {
    if (_value != newValue) {
      // Set this before proceeding to ensure no circular loop occurs with selection.
      _value = newValue;
      _updateSelectedRadioFromValue();
      // Only fire a change event if this isn't the first time the value is ever set.
      if (_isInitialized) {
        _emitChangeEvent();
      }
    }
  }

  MdRadioButton get selected => _selected;

  @Input()
  set selected(MdRadioButton selected) {
    _selected = selected;
    value = selected?.value;
    if (selected != null && !selected.checked) {
      selected.checked = true;
    }
  }

  /// Initialize properties once content children are available.
  /// This allows us to propagate relevant attributes to associated buttons.
  /// TODO: internal
  @override
  void ngAfterContentInit() {
    // Mark this component as initialized in AfterContentInit because the initial value can
    // possibly be set by NgModel on MdRadioGroup, and it is possible that the OnInit of the
    // NgModel occurs *after* the OnInit of the MdRadioGroup.
    _isInitialized = true;
  }

  /// Mark this group as being "touched" (for ngModel). Meant to be called by the contained
  /// radio buttons upon their blur.
  /// @internal
  void touch() {
    if (onTouched != null) onTouched();
  }

  void _updateRadioButtonNames() {
    if (radios != null) {
      radios.forEach((radio) {
        radio.name = name;
      });
    }
  }

  /** Updates the `selected` radio button from the internal _value state. */
  void _updateSelectedRadioFromValue() {
    // If the value already matches the selected radio, do nothing.
    var isAlreadySelected = _selected != null && _selected.value == _value;
    if (radios != null && !isAlreadySelected) {
      var matchingRadio = radios.firstWhere((radio) => radio.value == _value,
          orElse: () => null);
      if (matchingRadio != null) {
        selected = matchingRadio;
      } else if (value == null) {
        selected = null;
        radios.forEach((radio) {
          radio.checked = false;
        });
      }
    }
  }

  /** Dispatch change event with current selection and group value. */
  void _emitChangeEvent() {
    var event = new MdRadioChange();
    event.source = _selected;
    event.value = _value;
    _controlValueAccessorChangeFn(event.value);
    change.emit(event);
  }

  /**
   * Implemented as part of ControlValueAccessor.
   * TODO: internal
   */
  @override
  void writeValue(dynamic value) {
    value = value;
  }

  /**
   * Implemented as part of ControlValueAccessor.
   * TODO: internal
   */
  // void fn(dynamic value)
  @override
  void registerOnChange(dynamic fn) {
    _controlValueAccessorChangeFn = fn;
  }

  /**
   * Implemented as part of ControlValueAccessor.
   * TODO: internal
   */
  @override
  void registerOnTouched(dynamic fn) {
    onTouched = fn;
  }
}

@Component(
    selector: "md-radio-button",
    templateUrl: "radio.html",
    styleUrls: const ["radio.scss.css"],
    encapsulation: ViewEncapsulation.None,
    host: const {"(click)": "onClick(\$event)"})
class MdRadioButton implements OnInit {
  MdUniqueSelectionDispatcher radioDispatcher;
  @HostBinding("class.md-radio-focused")
  bool isFocused = false;

  /** Whether this radio is checked. */
  bool _checked = false;

  /** The unique ID for the radio button. */
  @HostBinding("id")
  @Input()
  String id = 'md-radio-${_uniqueIdCounter++}';

  /** Analog to HTML 'name' attribute used to group radios for unique selection. */
  @Input()
  String name;

  /** Used to set the 'aria-label' attribute on the underlying input element. */
  @Input("aria-label")
  String ariaLabel;

  /** The 'aria-labelledby' attribute takes precedence as the element's text alternative. */
  @Input("aria-labelledby")
  String ariaLabelledby;

  /** Whether this radio is disabled. */
  bool _disabled = false;

  /** Value assigned to this radio.*/
  dynamic _value;

  /** The parent radio group. May or may not be present. */
  MdRadioGroup radioGroup;

  /** Event emitted when the group value changes. */
  @Output()
  EventEmitter<MdRadioChange> change = new EventEmitter<MdRadioChange>();

  MdRadioButton(@Optional() MdRadioGroup radioGroup, this.radioDispatcher) {
    // Assertions. Ideally these should be stripped out by the compiler.

    // TODO(jelbourn): Assert that there's no name binding AND a parent radio group.
    this.radioGroup = radioGroup;
    radioDispatcher.listen((String id, String name) {
      if (id != this.id && name == this.name) checked = false;
    });
  }

  String get inputId => '$id-input';

  @HostBinding("class.md-radio-checked")
  bool get checked => _checked;

  @Input()
  set checked(bool newCheckedState) {
    if (newCheckedState) {
      // Notify all radio buttons with the same name to un-check.
      radioDispatcher.notify(id, name);
    }
    if (newCheckedState != _checked) {
      _emitChangeEvent();
    }
    _checked = newCheckedState;
    if (newCheckedState && radioGroup != null && radioGroup.value != value) {
      radioGroup.selected = this;
    }
  }

  /** MdRadioGroup reads this to assign its own value. */
  dynamic get value => _value;

  @Input()
  set value(dynamic value) {
    if (_value != value) {
      if (radioGroup != null && checked) {
        radioGroup.value = value;
      }
      _value = value;
    }
  }

  // start | end
  String _align;

  String get align {
    if (_align != null) return _align;
    if (radioGroup != null) return radioGroup.align;
    return "start";
  }

  @Input()
  set align(String value) {
    _align = value;
  }

  @HostBinding("class.md-radio-disabled")
  bool get disabled {
    return _disabled || (radioGroup != null && radioGroup.disabled);
  }

  @Input()
  set disabled(dynamic value) {
    // The presence of *any* disabled value makes the component disabled, *except* for false.
    _disabled = booleanFieldValue(value);
  }

  /** TODO: internal */
  @override
  void ngOnInit() {
    if (radioGroup != null) {
      // If the radio is inside a radio group, determine if it should be checked
      checked = identical(radioGroup.value, _value);
      // Copy name from parent radio group
      name = radioGroup.name;
    }
  }

  // Dispatch change event with current value.
  void _emitChangeEvent() {
    var event = new MdRadioChange();
    event.source = this;
    event.value = _value;
    change.emit(event);
  }

  // @internal
  void onClick(Event event) {
    if (disabled) {
      event.preventDefault();
      event.stopPropagation();
      return;
    }
    if (radioGroup != null) {
      // Propagate the change one-way via the group, which will in turn mark this
      // button as checked.
      radioGroup.selected = this;
      radioGroup.touch();
    } else {
      checked = true;
    }
  }

  /// We use a hidden native input field to handle changes to focus state via keyboard navigation,
  ///  with visual rendering done separately. The native element is kept in sync with the overall
  ///  state of the component.
  ///  @internal
  void onInputFocus() {
    isFocused = true;
  }

  // @internal
  void onInputBlur() {
    isFocused = false;
    if (radioGroup != null) {
      radioGroup.touch();
    }
  }

  /// Checks the radio due to an interaction with the underlying native <input type="radio">
  /// @internal
  void onInputChange(Event event) {
    // We always have to stop propagation on the change event.
    // Otherwise the change event, from the input element, will bubble up and
    // emit its event object to the `change` output.
    event.stopPropagation();
    checked = true;
    if (radioGroup != null) {
      radioGroup.touch();
    }
  }
}

const List MD_RADIO_DIRECTIVES = const [MdRadioGroup, MdRadioButton];
