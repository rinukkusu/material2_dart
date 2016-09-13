import 'dart:html';
import 'dart:async';
import "package:angular2/core.dart";
import "package:angular2/common.dart";
import "package:material2_dart/core/annotations/field_value.dart";

const Provider MD_SLIDE_TOGGLE_VALUE_ACCESSOR =
    const Provider(NG_VALUE_ACCESSOR, useExisting: MdSlideToggle, multi: true);

// A simple change event emitted by the MdSlideToggle component.
class MdSlideToggleChange {
  MdSlideToggle source;
  bool checked;
}

// Increasing integer for generating unique ids for slide-toggle components.
int nextId = 0;

@Component(
    selector: "md-slide-toggle",
    host: const {
      "[class.md-checked]": "checked",
      "[class.md-disabled]": "disabled",
      // This md-slide-toggle prefix will change, once the temporary ripple is removed.
      "[class.md-slide-toggle-focused]": "hasFocus",
      "(mousedown)": "setMousedown()"
    },
    templateUrl: "slide_toggle.html",
    styleUrls: const ["slide_toggle.scss.css"],
    providers: const [MD_SLIDE_TOGGLE_VALUE_ACCESSOR],
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdSlideToggle implements ControlValueAccessor<dynamic> {
  ElementRef _elementRef;
  Renderer _renderer;
  Function onChange = (dynamic _) {};
  Function onTouched = () {};

  // A unique id for the slide-toggle. By default the id is auto-generated.
  String _uniqueId = 'md-slide-toggle-$nextId';
  bool _checked = false;
  String _color;
  bool hasFocus = false;
  bool _isMousedown = false;

  @Input()
  set disabled(dynamic v) {
    _disabled = booleanFieldValue(v);
  }

  bool get disabled => _disabled;
  bool _disabled = false;

  @Input()
  String name;

  String get id {
    nextId++;
    return _uniqueId;
  }

  @Input()
  set id(String v) {
    _uniqueId = v;
  }

  @Input()
  int tabIndex = 0;

  @Input()
  String ariaLabel;

  @Input()
  String ariaLabelledby;

  EventEmitter<MdSlideToggleChange> _change =
      new EventEmitter<MdSlideToggleChange>();

  @Output()
  Stream<MdSlideToggleChange> get change => _change;

  // Returns the unique id for the visual hidden input.
  String getInputId() => '$id-input';

  MdSlideToggle(this._elementRef, this._renderer);

  /**
   * The onChangeEvent method will be also called on click.
   * This is because everything for the slide-toggle is wrapped inside of a label,
   * which triggers a onChange event on click.
   * @internal
   */
  void onChangeEvent(Event event) {
    // We always have to stop propagation on the change event.
    // Otherwise the change event, from the input element, will bubble up and
    // emit its event object to the component's `change` output.
    event.stopPropagation();
    if (!disabled) toggle();
  }

  /** @internal */
  void onInputClick(Event event) {
    onTouched();
    // We have to stop propagation for click events on the visual hidden input element.
    // By default, when a user clicks on a label element, a generated click event will be
    // dispatched on the associated input element. Since we are using a label element as our
    // root container, the click event on the `slide-toggle` will be executed twice.
    // The real click event will bubble up, and the generated click event also tries to bubble up.
    // This will lead to multiple click events.
    // Preventing bubbling for the second event will solve that issue.
    event.stopPropagation();
  }

  /** @internal */
  void setMousedown() {
    // We only *show* the focus style when focus has come to the button via the keyboard.
    // The Material Design spec is silent on this topic, and without doing this, the
    // button continues to look :active after clicking.
    // @see http://marcysutton.com/button-focus-hell/
    _isMousedown = true;
    new Future<Null>.delayed(const Duration(milliseconds: 100), () {
      _isMousedown = false;
    });
  }

  /** @internal */
  void onInputFocus() {
    // Only show the focus / ripple indicator when the focus was not triggered by a mouse
    // interaction on the component.
    if (!_isMousedown) hasFocus = true;
  }

  /** @internal */
  void onInputBlur() {
    hasFocus = false;
    onTouched();
  }

  /**
   * Implemented as part of ControlValueAccessor.
   * TODO: internal
   */
  @override
  void writeValue(dynamic value) {
    checked = value;
  }

  /// Implemented as part of ControlValueAccessor.
  /// TODO: internal
  @override
  void registerOnChange(dynamic fn) {
    onChange = fn as Function;
  }

  /// mplemented as part of ControlValueAccessor.
  /// TODO: internal
  @override
  void registerOnTouched(dynamic fn) {
    onTouched = fn as Function;
  }

  bool get checked => _checked;

  @Input()
  set checked(dynamic value) {
    bool v = booleanFieldValue(value);
    if (!identical(checked, v)) {
      _checked = v;
      onChange(_checked);
      _emitChangeEvent();
    }
  }

  String get color => _color;

  @Input()
  set color(String value) {
    _updateColor(value);
  }

  void toggle() {
    checked = !checked;
  }

  void _updateColor(String newColor) {
    _setElementColor(_color, false);
    _setElementColor(newColor, true);
    _color = newColor;
  }

  void _setElementColor(String color, bool isAdd) {
    if (color != null && color != "") {
      _renderer.setElementClass(_elementRef.nativeElement, 'md-$color', isAdd);
    }
  }

  void _emitChangeEvent() {
    var event = new MdSlideToggleChange();
    event.source = this;
    event.checked = checked;
    _change.emit(event);
  }
}

const List MD_SLIDE_TOGGLE_DIRECTIVES = const [MdSlideToggle];
