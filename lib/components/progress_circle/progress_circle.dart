import 'dart:html';
import 'dart:async';
import 'dart:math' as math;
import "package:angular2/core.dart";
// TODO(josephperrott): Benchpress tests.

/// A single degree in radians.
const num degreeInRadiants = math.PI / 180;
//// Duration of the indeterminate animation.
const int durationIndeterminate = 667;

/// Duration of the indeterminate animation.
const int durationDeterminate = 225;

/// Start animation value of the indeterminate animation
const num startIndeterminate = 3;

/// End animation value of the indeterminate animation
const num endIndeterminate = 80;

enum ProgressCircleMode { determinate, indeterminate }

typedef num EasingFn(
    num currentTime, num startValue, num changeValue, num duration);

/**
 * <md-progress-circle> component.
 */
@Component(
    selector: "md-progress-circle",
    host: const {
      "role": "progressbar",
      "[attr.aria-valuemin]": "ariaValueMin",
      "[attr.aria-valuemax]": "ariaValueMax"
    },
    templateUrl: "progress_circle.html",
    styleUrls: const ["progress_circle.scss.css"],
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdProgressCircle implements OnDestroy {
  ChangeDetectorRef _changeDetectorRef;

  /** The id of the last requested animation. */
  num _lastAnimationId = 0;

  /** The Timer of the indeterminate interval. */
  Timer _interdeterminateInterval;

  /**
   * Values for aria max and min are only defined as numbers when in a determinate mode.  We do this
   * because voiceover does not report the progress indicator as indeterminate if the aria min
   * and/or max value are number values.
   *
   */
  num get ariaValueMin => mode == "determinate" ? 0 : null;

  num get ariaValueMax => mode == "determinate" ? 100 : null;

  Timer get interdeterminateInterval => _interdeterminateInterval;

  set interdeterminateInterval(Timer interval) {
    _interdeterminateInterval?.cancel();
    _interdeterminateInterval = interval;
  }

  /** The current path value, representing the progress circle. */
  String _currentPath;

  String get currentPath => _currentPath;

  set currentPath(String path) {
    _currentPath = path;
    // Mark for check as our ChangeDetectionStrategy is OnPush, when changes come from within the
    // component, change detection must be called for.
    _changeDetectorRef.markForCheck();
  }

  // Clean up any animations that were running.
  @override
  void ngOnDestroy() {
    _cleanupIndeterminateAnimation();
  }

  /**
   * Value of the progress circle.
   *
   * Input:number
   * _value is bound to the host as the attribute aria-valuenow.
   */
  num _value;

  @HostBinding("attr.aria-valuenow")
  num get value {
    if (mode == "determinate") {
      return _value;
    }
    return null;
  }

  @Input()
  set value(num v) {
    if (v != null && v != 0 && mode == "determinate") {
      var newValue = clamp(v);
      _animateCircle(
          (value ?? 0), newValue, linearEase, durationDeterminate, 0);
      _value = newValue;
    }
  }

  /**
   * Mode of the progress circle
   *
   * Input must be one of the values from ProgressMode, defaults to 'determinate'.
   * mode is bound to the host as the attribute host.
   */
  @HostBinding("attr.mode")
  String get mode =>
      _mode == ProgressCircleMode.determinate ? 'determinate' : 'indeterminate';

  @Input()
  set mode(String m) {
    if (!['determinate', 'indeterminate'].contains(m)) {
      throw new ArgumentError(
          'Only determinate and indeterminate are allowed.');
    }
    if (m == "indeterminate") {
      _startIndeterminateAnimation();
      _mode = ProgressCircleMode.indeterminate;
    } else {
      _cleanupIndeterminateAnimation();
      _mode = ProgressCircleMode.determinate;
    }
  }

  ProgressCircleMode _mode = ProgressCircleMode.determinate;

  MdProgressCircle(this._changeDetectorRef);

  /**
   * Animates the circle from one percentage value to another.
   *
   * @param animateFrom The percentage of the circle filled starting the animation.
   * @param animateTo The percentage of the circle filled ending the animation.
   * @param ease The easing function to manage the pace of change in the animation.
   * @param duration The length of time to show the animation, in milliseconds.
   * @param rotation The starting angle of the circle fill, with 0° represented at the top center of the circle.
   */
  void _animateCircle(num animateFrom, num animateTo, EasingFn ease,
      num duration, num rotation) {
    num id = ++_lastAnimationId;
    num startTime = now();
    num changeInValue = animateTo - animateFrom;

    // No need to animate it if the values are the same
    if (animateTo == animateFrom) {
      currentPath = getSvgArc(animateTo, rotation);
    } else {
      window.animationFrame.then/*<num>*/((num _) {
        _animation(id, startTime, animateFrom, changeInValue, duration,
            rotation, ease);
      });
    }
  }

  void _animation(num id, num startTime, num animateFrom, num changeInValue,
      num duration, num rotation, EasingFn ease) {
    var currentTime = now();
    num elapsedTime = math.max(0, math.min(currentTime - startTime, duration));
    currentPath = getSvgArc(
        ease(elapsedTime, animateFrom, changeInValue, duration), rotation);
    // Prevent overlapping animations by checking if a new animation has been called for and
    // if the animation has lasted long than the animation duration.
    if (id == _lastAnimationId && elapsedTime < duration) {
      window.animationFrame.then/*<num>*/((num _) {
        _animation(id, startTime, animateFrom, changeInValue, duration,
            rotation, ease);
      });
    }
  }

  ///Starts the indeterminate animation interval, if it is not already running.
  void _startIndeterminateAnimation() {
    num rotationStartPoint = 0;
    num start = startIndeterminate;
    num end = endIndeterminate;
    num duration = durationIndeterminate;
    var animate = () {
      _animateCircle(start, end, materialEase, duration, rotationStartPoint);
      // Prevent rotation from reaching Number.MAX_SAFE_INTEGER.
      rotationStartPoint = (rotationStartPoint + end) % 100;
      var temp = start;
      start = -end;
      end = -temp;
    };
    if (interdeterminateInterval == null) {
      interdeterminateInterval = new Timer.periodic(
          new Duration(milliseconds: duration.toInt() + 50), (_) => animate);
      animate();
    }
  }

  /**
   * Removes interval, ending the animation.
   */
  void _cleanupIndeterminateAnimation() {
    interdeterminateInterval = null;
  }
}

/**
 * <md-spinner> component.
 *
 * This is a component definition to be used as a convenience reference to create an
 * indeterminate <md-progress-circle> instance.
 */
@Component(
    selector: "md-spinner",
    host: const {"role": "progressbar", "mode": "indeterminate"},
    templateUrl: "progress_circle.html",
    styleUrls: const ["progress_circle.scss.css"])
class MdSpinner extends MdProgressCircle {
  MdSpinner(ChangeDetectorRef changeDetectorRef) : super(changeDetectorRef) {
    mode = "indeterminate";
  }
}

/**
 * Module functions.
 */

/** Clamps a value to be between 0 and 100. */
num clamp(num v) {
  return math.max(0, math.min(100, v));
}

/// Returns the current timestamp either based on the performance global
/// or a date object.
num now() => new DateTime.now().millisecondsSinceEpoch;

/**
 * Converts Polar coordinates to Cartesian.
 */
String polarToCartesian(num radius, num pathRadius, num angleInDegrees) {
  var angleInRadians = (angleInDegrees - 90) * degreeInRadiants;
  return (radius + (pathRadius * math.cos(angleInRadians))).toString() +
      "," +
      (radius + (pathRadius * math.sin(angleInRadians))).toString();
}

/**
 * Easing function for linear animation.
 */
num linearEase(
    num currentTime, num startValue, num changeInValue, num duration) {
  return changeInValue * currentTime / duration + startValue;
}

/**
 * Easing function to match material design indeterminate animation.
 */
num materialEase(
    num currentTime, num startValue, num changeInValue, num duration) {
  var time = currentTime / duration;
  var timeCubed = math.pow(time, 3);
  var timeQuad = math.pow(time, 4);
  var timeQuint = math.pow(time, 5);
  return startValue +
      changeInValue * ((6 * timeQuint) + (-15 * timeQuad) + (10 * timeCubed));
}

/**
 * Determines the path value to define the arc.  Converting percentage values to to polar
 * coordinates on the circle, and then to cartesian coordinates in the viewport.
 *
 * @param currentValue The current percentage value of the progress circle, the percentage of the
 *    circle to fill.
 * @param rotation The starting point of the circle with 0 being the 0 degree point.
 * @return A string for an SVG path representing a circle filled from the starting point to the
 *    percentage value provided.
 */
String getSvgArc(num currentValue, num rotation) {
  // The angle can't be exactly 360, because the arc becomes hidden.
  var maximumAngle = 359.99 / 100;
  var startPoint = rotation ?? 0;
  var radius = 50;
  var pathRadius = 40;
  var startAngle = startPoint * maximumAngle;
  var endAngle = currentValue * maximumAngle;
  var start = polarToCartesian(radius, pathRadius, startAngle);
  var end = polarToCartesian(radius, pathRadius, endAngle + startAngle);
  var arcSweep = endAngle < 0 ? 0 : 1;
  num largeArcFlag;
  if (endAngle < 0) {
    largeArcFlag = endAngle >= -180 ? 0 : 1;
  } else {
    largeArcFlag = endAngle <= 180 ? 0 : 1;
  }
  return 'M${start}A$pathRadius,$pathRadius 0 $largeArcFlag,$arcSweep $end';
}

const List MD_PROGRESS_CIRCLE_DIRECTIVES = const [MdProgressCircle, MdSpinner];
