import 'dart:html';
import 'dart:math' as math;
import 'package:angular2/angular2.dart';
import 'package:angular2/common.dart';
import '../../core/core.dart'
    show coerceBooleanProperty, applyCssTransform, numFieldValue;

/// Visually, a 30px separation between tick marks looks best.
/// This is very subjective but it is the default separation we chose.
const num MIN_AUTO_TICK_SEPARATION = 30;

/// Provider Expression that allows md-slider to register as a ControlValueAccessor.
/// This allows it to support [(ngModel)] and formControl.
const Provider MD_SLIDER_VALUE_ACCESSOR =
    const Provider(NG_VALUE_ACCESSOR, useExisting: MdSlider, multi: true);

typedef void _ControlValueAccessorChangeFn(dynamic value);

@Component(
  selector: 'md-slider',
  providers: const [MD_SLIDER_VALUE_ACCESSOR],
  host: const {
    'tabindex': '0',
    '(click)': r'onClick($event)',
    '(slide)': r'onSlide($event)',
    '(slidestart)': r'onSlideStart($event)',
    '(slideend)': 'onSlideEnd()',
    '(resize)': 'onResize()',
    '(blur)': 'onBlur()',
  },
  templateUrl: 'slider.html',
  styleUrls: const ['slider.scss.css'],
  encapsulation: ViewEncapsulation.None,
)
class MdSlider implements AfterContentInit, ControlValueAccessor<dynamic> {
  /// A renderer to handle updating the slider's thumb and fill track.
  SliderRenderer _renderer;

  /// The dimensions of the slider.
  Rectangle _sliderDimensions;

  bool _disabled = false;

  @HostBinding('class.md-slider-disabled')
  @HostBinding('attr.aria-disabled')
  bool get disabled => _disabled;

  @Input()
  set disabled(dynamic value) {
    _disabled = coerceBooleanProperty(value);
  }

  bool _thumbLabel = false;

  bool get thumbLabel => _thumbLabel;

  /// Whether or not to show the thumb label.
  @Input('thumb-label')
  set thumbLabel(dynamic value) {
    _thumbLabel = coerceBooleanProperty(value);
  }

  /// The miniumum value that the slider can have.
  num _min = 0;

  /// The percentage of the slider that coincides with the value. */
  num _percent = 0;

  _ControlValueAccessorChangeFn _controlValueAccessorChangeFn =
      (dynamic value) {};

  /// onTouch function registered via registerOnTouch (ControlValueAccessor).
  Function onTouched = () {};

  num _step = 1;

  num get step => _step;

  /// The values at which the thumb will snap.
  @Input()
  set step(dynamic value) {
    _step = numFieldValue(value);
  }

  dynamic _tickInterval = 0;

  /// 'auto' | num
  dynamic get tickInterval => _tickInterval;

  /// How often to show ticks. Relative to the step so that a tick always appears on a step.
  /// Ex: Tick interval of 4 with a step of 3 will draw a tick every 4 steps (every 12 values).
  @Input('tick-interval')
  set tickInterval(dynamic value) {
    if (value == null) {
      _tickInterval = 0;
    } else if (value is num) {
      _tickInterval = value;
    } else if (value is String) {
      if (value == 'auto') {
        _tickInterval = value;
      } else {
        _tickInterval = numFieldValue(value);
      }
    } else {
      throw new ArgumentError.value(value);
    }
  }

  /// Whether or not the thumb is sliding.
  /// Used to determine if there should be a transition for the thumb and fill track.
  bool isSliding = false;

  ///Whether or not the slider is active (clicked or sliding).
  /// Used to shrink and grow the thumb as according to the Material Design spec.
  bool isActive = false;

  /// Indicator for if the value has been set or not.
  bool _isInitialized = false;

  /// Value of the slider.
  num _value = 0;

  @HostBinding('attr.aria-valuemin')
  num get min => _min;

  @Input()
  set min(dynamic value) {
    _min = numFieldValue(value);
    // If the value wasn't explicitly set by the user, set it to the min.
    if (!_isInitialized) value = _min;

    snapThumbToValue();
    _updateTickSeparation();
  }

  num _max = 100;

  /// The maximum value that the slider can have.
  @HostBinding('attr.aria-valuemax')
  num get max => _max;

  @Input()
  set max(dynamic value) {
    _max = numFieldValue(value);
    snapThumbToValue();
    _updateTickSeparation();
  }

  @HostBinding('attr.aria-valuenow')
  num get value => _value;

  // String | num
  @Input()
  set value(dynamic v) {
    if (v != null) {
      _value = numFieldValue(v);
      _isInitialized = true;
      _controlValueAccessorChangeFn(_value);
      snapThumbToValue();
    }
  }

  MdSlider(ElementRef elementRef)
      : this._renderer = new SliderRenderer(elementRef);

  /// Once the slider has rendered, grab the dimensions
  /// and update the position of the thumb and fill track.
  @override
  void ngAfterContentInit() {
    _sliderDimensions = _renderer.getSliderDimensions();
    // This needs to be called after content init because the value can be set to the min if the
    // value itself isn't set. If this happens, the control value accessor needs to be updated.
    _controlValueAccessorChangeFn(value);
    snapThumbToValue();
    _updateTickSeparation();
  }

  void onClick(MouseEvent event) {
    if (disabled) {
      return;
    }

    isActive = true;
    isSliding = false;
    _renderer.addFocus();
    updateValueFromPosition(event.client.x);
    snapThumbToValue();
  }

  // FIXME: Blocked by Hammer not being ported.
//  void onSlide(HammerInput event) {
//    if (disabled) {
//      return;
//    }
//
//    // Prevent the slide from selecting anything else.
//    event.preventDefault();
//    updateValueFromPosition(event.center.x);
//  }

  // FIXME: Blocked by Hammer not being ported.
//  void onSlideStart(HammerInput event) {
//    if (disabled) {
//      return;
//    }
//
//    event.preventDefault();
//    isSliding = true;
//    isActive = true;
//    _renderer.addFocus();
//    updateValueFromPosition(event.center.x);
//  }

  void onSlideEnd() {
    isSliding = false;
    snapThumbToValue();
  }

  void onResize() {
    isSliding = true;
    _sliderDimensions = _renderer.getSliderDimensions();
    // Skip updating the value and position as there is no new placement.
    _renderer.updateThumbAndFillPosition(_percent, _sliderDimensions.width);
  }

  void onBlur() {
    isActive = false;
    onTouched();
  }

  /// When the value changes without a physical position, the percentage needs to be recalculated
  /// independent of the physical location.
  /// This is also used to move the thumb to a snapped value once sliding is done.
  void updatePercentFromValue() {
    _percent = calculatePercentage(value);
  }

  /// Calculate the new value from the new physical location.
  /// The value will always be snapped.
  void updateValueFromPosition(num pos) {
    num offset = _sliderDimensions.left;
    num size = _sliderDimensions.width;

    // The exact value is calculated from the event and used to find the closest snap value.
    _percent = clamp((pos - offset) / size);
    var exactValue = calculateValue(_percent);

    // This calculation finds the closest step by finding the closest whole number divisible by the
    // step relative to the min.
    num closestValue = ((exactValue - min) / step).round() * step + min;
    // The value needs to snap to the min and max.
    value = clamp(closestValue, min, max);
    _renderer.updateThumbAndFillPosition(_percent, _sliderDimensions.width);
  }

  /// Snaps the thumb to the current value.
  /// Called after a click or drag event is over.
  void snapThumbToValue() {
    updatePercentFromValue();
    if (_sliderDimensions != null) {
      var renderedPercent = clamp(_percent);
      _renderer.updateThumbAndFillPosition(
          renderedPercent, _sliderDimensions.width);
    }
  }

  /// Calculates the separation in pixels of tick marks. If there is no tick interval or the interval
  /// is set to something other than a number or 'auto', nothing happens.
  void _updateTickSeparation() {
    if (_sliderDimensions == null) return;

    if (_tickInterval == 'auto') {
      _updateAutoTickSeparation();
    } else {
      _updateTickSeparationFromInterval();
    }
  }

  /**
   * Calculates the optimal separation in pixels of tick marks based on the minimum auto tick
   * separation constant.
   */
  void _updateAutoTickSeparation() {
    // We're looking for the multiple of step for which the separation between is greater than the
    // minimum tick separation.
    num sliderWidth = _sliderDimensions.width;

    // This is the total "width" of the slider in terms of values.
    num valueWidth = max - min;

    // Calculate how many values exist within 1px on the slider.
    num valuePerPixel = valueWidth / sliderWidth;

    // Calculate how many values exist in the minimum tick separation (px).
    num valuePerSeparation = valuePerPixel * MIN_AUTO_TICK_SEPARATION;

    // Calculate how many steps exist in this separation. This will be the lowest value you can
    // multiply step by to get a separation that is greater than or equal to the minimum tick
    // separation.
    int stepsPerSeparation = (valuePerSeparation / step).ceil();

    // Get the percentage of the slider for which this tick would be located so we can then draw
    // it on the slider.
    num tickPercentage = calculatePercentage((step * stepsPerSeparation) + min);

    // The pixel value of the tick is the percentage * the width of the slider. Use this to draw
    // the ticks on the slider.
    _renderer.drawTicks(sliderWidth * tickPercentage);
  }

  /// Calculates the separation of tick marks by finding the pixel value of the tickInterval.
  void _updateTickSeparationFromInterval() {
    assert(_tickInterval is num);
    // Calculate the first value a tick will be located at by getting the step at which the interval
    // lands and adding that to the min.
    num tickValue = (step * _tickInterval) + min;

    // The percentage of the step on the slider is needed in order to calculate the pixel offset
    // from the beginning of the slider. This offset is the tick separation.
    num tickPercentage = calculatePercentage(tickValue);
    _renderer.drawTicks(_sliderDimensions.width * tickPercentage);
  }

  /// Calculates the percentage of the slider that a value is.
  num calculatePercentage(num value) {
    return (value - min) / (max - min);
  }

  /// Calculates the value a percentage of the slider corresponds to.
  num calculateValue(num percentage) {
    return min + (percentage * (max - min));
  }

  /// Return a number between two numbers.
  num clamp(num value, [num min = 0, num max = 1]) {
    return math.max(min, math.min(value, max));
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void writeValue(dynamic value) {
    this.value = value;

    if (_sliderDimensions != null) {
      snapThumbToValue();
    }
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void registerOnChange(_ControlValueAccessorChangeFn fn) {
    _controlValueAccessorChangeFn = fn;
  }

  /// Implemented as part of ControlValueAccessor.
  @override
  void registerOnTouched(Function fn) {
    onTouched = fn;
  }

  /// Implemented as part of ControlValueAccessor.
  void setDisabledState(bool isDisabled) {
    disabled = isDisabled;
  }
}

/// Renderer class in order to keep all dom manipulation in one place and outside of the main class.
class SliderRenderer {
  Element _sliderElement;

  SliderRenderer(ElementRef elementRef)
      : _sliderElement = elementRef.nativeElement;

  /// Get the bounding client rect of the slider track element.
  /// The track is used rather than the native element to ignore the extra space
  /// that the thumb can take up.
  Rectangle getSliderDimensions() {
    Element trackElement = _sliderElement.querySelector('.md-slider-track');
    return trackElement.getBoundingClientRect();
  }

  /// Update the physical position of the thumb and fill track on the slider.
  void updateThumbAndFillPosition(num percent, num width) {
    // A container element that is used to avoid overwriting the transform on the thumb itself.
    var thumbPositionElement =
        _sliderElement.querySelector('.md-slider-thumb-position');
    var fillTrackElement =
        _sliderElement.querySelector('.md-slider-track-fill');

    num position = (percent * width).round();

    fillTrackElement.style.width = '${position}px';
    applyCssTransform(thumbPositionElement, 'translateX(${position}px)');
  }

  /// Focuses the native element.
  /// Currently only used to allow a blur event to fire but will be used with keyboard input later.
  void addFocus() {
    _sliderElement.focus();
  }

  /// Draws ticks onto the tick container.
  void drawTicks(num tickSeparation) {
    var sliderTrackContainer =
        _sliderElement.querySelector('.md-slider-track-container');
    var tickContainerWidth = sliderTrackContainer.getBoundingClientRect().width;
    var tickContainer =
        _sliderElement.querySelector('.md-slider-tick-container');
    // An extra element for the last tick is needed because the linear gradient cannot be told to
    // always draw a tick at the end of the gradient. To get around this, there is a second
    // container for ticks that has a single tick mark on the very right edge.
    var lastTickContainer =
        _sliderElement.querySelector('.md-slider-last-tick-container');
    // Subtract 1 from the tick separation to center the tick.
    // TODO: Evaluate the rendering performance of using repeating background gradients.
    tickContainer.style.background =
        'repeating-linear-gradient(to right, black, black 2px, ' +
            'transparent 2px, transparent ${tickSeparation - 1}px)';
    // Add a tick to the very end by starting on the right side and adding a 2px black line.
    lastTickContainer.style.background =
        'linear-gradient(to left, black, black 2px, transparent ' +
            '2px, transparent)';

    if (tickContainerWidth % tickSeparation < (tickSeparation / 2)) {
      // If the second to last tick is too close (a separation of less than half the normal
      // separation), don't show it by decreasing the width of the tick container element.
      tickContainer.style.width = '${tickContainerWidth - tickSeparation}px';
    } else {
      // If there is enough space for the second-to-last tick, restore the default width of the
      // tick container.
      tickContainer.style.width = '';
    }
  }
}

const List MD_SLIDER_DIRECTIVES = const <dynamic>[MdSlider];
