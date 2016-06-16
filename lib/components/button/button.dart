import 'dart:html';
import 'dart:async';
import 'package:angular2/core.dart';

// TODO(jelbourn): Ink ripples.
// TODO(jelbourn): Make the `isMouseDown` stuff done with one global listener.
// TODO(kara): Convert attribute selectors to classes when attr maps become available

@Component(
    selector:
        'button[md-button], button[md-raised-button], button[md-icon-button], button[md-fab], button[md-mini-fab]',
    inputs: const ['color'],
    host: const {
      '[class.md-button-focus]': 'isKeyboardFocused',
      '(mousedown)': 'setMousedown()',
      '(focus)': 'setKeyboardFocus()',
      '(blur)': 'removeKeyboardFocus()',
    },
    templateUrl: 'button.html',
    styleUrls: const ['button.css'],
    encapsulation: ViewEncapsulation.None,
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdButton {
  String _color;

  /// Whether the button has focus from the keyboard (not the mouse). Used for class binding.
  bool isKeyboardFocused = false;

  /// Whether a mousedown has occurred on this element in the last 100ms.
  bool isMouseDown = false;

  ElementRef _elementRef;
  Renderer _renderer;

  MdButton(this._elementRef, this._renderer);

  String get color => _color;

  void set color(String value) {
    _updateColor(value);
  }

  // TODO: Confirm this method work after making it private.
  /** @internal */
  void setMousedown() {
    // We only *show* the focus style when focus has come to the button via the keyboard.
    // The Material Design spec is silent on this topic, and without doing this, the
    // button continues to look :active after clicking.
    // @see http://marcysutton.com/button-focus-hell/
    isMouseDown = true;
    new Timer(const Duration(milliseconds: 100), () => isMouseDown = false);
  }

  void _updateColor(String newColor) {
    this._setElementColor(_color, false);
    this._setElementColor(newColor, true);
    _color = newColor;
  }

  void _setElementColor(String color, bool isAdd) {
    if (color != null && color.isNotEmpty) {
      assert(this._elementRef != null);
      _renderer.setElementClass(
          this._elementRef.nativeElement, 'md-$color', isAdd);
    }
  }

  /** @internal */
  void setKeyboardFocus() {
    isKeyboardFocused = !isMouseDown;
  }

  /** @internal */
  void removeKeyboardFocus() {
    isKeyboardFocused = false;
  }

  /** TODO(hansl): e2e test this function. */
  focus() {
    _elementRef.nativeElement.focus();
  }
}

@Component(
    selector:
        'a[md-button], a[md-raised-button], a[md-icon-button], a[md-fab], a[md-mini-fab]',
    inputs: const ['color'],
    host: const {
      '[class.md-button-focus]': 'isKeyboardFocused',
      '(mousedown)': 'setMousedown()',
      '(focus)': 'setKeyboardFocus()',
      '(blur)': 'removeKeyboardFocus()',
      '(click)': 'haltDisabledEvents(\$event)',
    },
    templateUrl: 'button.html',
    styleUrls: const ['button.css'],
    encapsulation: ViewEncapsulation.None)
class MdAnchor extends MdButton {
  bool _disabled = false;

  MdAnchor(ElementRef _elementRef, Renderer _renderer)
      : super(_elementRef, _renderer);

  @HostBinding('tabIndex')
  int get tabIndex => _disabled ? -1 : 0;

  @HostBinding('attr.aria-disabled')
  // Gets the aria-disabled value for the component, which must be a string for Dart.
  String get isAriaDisabled => _disabled ? 'true' : 'false';

  @HostBinding('attr.disabled')
  @Input('disabled')
  bool get disabled => _disabled;

  // The presence of *any* disabled value makes the component disabled, *except* for false.
  void set disabled(bool value) {
    _disabled = value != null && value != false;
  }

  /** @internal */
  haltDisabledEvents(Event event) {
    // A disabled button shouldn't apply any actions
    if (_disabled) {
      event.preventDefault();
      event.stopImmediatePropagation();
    }
  }
}

const MD_BUTTON_DIRECTIVES = const [MdButton, MdAnchor];
