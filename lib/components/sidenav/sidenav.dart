import 'dart:html';
import 'dart:async';
import 'package:angular2/core.dart';
import 'package:material2_dart/core/rtl/dir.dart';
import 'package:material2_dart/core/errors/error.dart';

/** Exception thrown when two MdSidenav are matching the same side. */
class MdDuplicatedSidenavError extends MdError {
  MdDuplicatedSidenavError(String align)
      : super("A sidenav was already declared for 'align=$align'");
}

// Because Dart doesn't have union types.
void valueConstraint(dynamic value, List<dynamic> list) {
  if (!list.contains(value)) throw new StateError('Invalid value: $value');
}

/**
 * <md-sidenav> component.
 *
 * This component corresponds to the drawer of the sidenav.
 *
 * Please refer to README.md for examples on how to use it.
 */
@Component(
    selector: 'md-sidenav',
    template: '<ng-content></ng-content>',
    host: const {'(transitionend)': r'onTransitionEnd($event)'},
    changeDetection: ChangeDetectionStrategy.OnPush)
class MdSidenav {
  /** Alignment of the sidenav (direction neutral); whether 'start' or 'end'. */
  String _align = 'start';

  String get align => _align;

  @Input()
  void set align(String value) {
    valueConstraint(value, ['start', 'end']);
    _align = value;
  }

  /** Mode of the sidenav; whether 'over' or 'side'. */
  String _mode = 'over';

  String get mode => _mode;

  @Input()
  void set mode(String value) {
    valueConstraint(value, ['over', 'push', 'side']);
    _mode = value;
  }

  /** Whether the sidenav is opened. */
  bool _opened = false;

  bool get opened => _opened;

  @Input()
  void set opened(dynamic value) {
    valueConstraint(value, ['true', 'false', true, false, null]);
    if (value == null) {
      value = false;
    } else if (value is String) {
      value = value == 'true';
    }
    toggle(value);
  }

  /** Event emitted when the sidenav is being opened. Use this to synchronize animations. */
  @Output('open-start')
  EventEmitter onOpenStart = new EventEmitter();

  /** Event emitted when the sidenav is fully opened. */
  @Output('open')
  EventEmitter onOpen = new EventEmitter();

  /** Event emitted when the sidenav is being closed. Use this to synchronize animations. */
  @Output('close-start')
  EventEmitter onCloseStart = new EventEmitter();

  /** Event emitted when the sidenav is fully closed. */
  @Output('close')
  EventEmitter onClose = new EventEmitter();

  // This should be private but currently is public just for testing.
  ElementRef elementRef;

  MdSidenav(this.elementRef);

  /** Open this sidenav, and return a Promise that will resolve when it's fully opened (or get
   * rejected if it didn't). */
  Future open() {
    return toggle(true);
  }

  /**
   * Close this sidenav, and return a Promise that will resolve when it's fully closed (or get
   * rejected if it didn't).
   */
  Future close() {
    return toggle(false);
  }

  Future toggle([bool isOpen]) {
    if (isOpen == null) isOpen = !opened;
    if (isOpen == opened) {
      if (!_transition) {
        return new Future.value();
      } else {
        return isOpen ? _openFuture : _closeFuture;
      }
    }
    _opened = isOpen;
    _transition = true;

    if (isOpen) {
      onOpenStart.emit(null);
    } else {
      onCloseStart.emit(null);
    }

    if (isOpen) {
      if (_openFuture == null) {
        var completer = new Completer();
        _openFuture = completer.future;
        _openFutureError = completer.completeError;
        _openFutureSuccess = completer.complete;
      }
      return _openFuture;
    } else {
      if (_closeFuture == null) {
        var completer = new Completer();
        _closeFuture = completer.future;
        _closeFutureError = completer.completeError;
        _closeFutureSuccess = completer.complete;
      }
      return _closeFuture;
    }
  }

  /**
   * When transition has finished, set the internal state for classes and emit the proper event.
   * The event passed is actually of type TransitionEvent, but that type is not available in
   * Android so we use any.
   * @internal
   */
  onTransitionEnd(TransitionEvent transitionEvent) {
    if (transitionEvent.target == elementRef.nativeElement &&
        // Simpler version to check for prefixes.
        transitionEvent.propertyName.endsWith('transform')) {
      _transition = false;
      if (_opened) {
        if (_openFuture != null) _openFutureSuccess();
        if (_closeFuture != null) _closeFutureError();
        onOpen.emit(null);
      } else {
        if (_closeFuture != null) _closeFutureSuccess();
        if (_openFuture != null) _openFutureError();
        onClose.emit(null);
      }
      _openFuture = null;
      _closeFuture = null;
    }
  }

  @HostBinding('class.md-sidenav-closing')
  bool get isClosing => !_opened && _transition;

  @HostBinding('class.md-sidenav-opening')
  bool get isOpening => _opened && _transition;

  @HostBinding('class.md-sidenav-closed')
  bool get isClosed => !_opened && !_transition;

  @HostBinding('class.md-sidenav-opened')
  bool get isOpened => _opened && !_transition;

  @HostBinding('class.md-sidenav-end')
  bool get isEnd => align == 'end';

  @HostBinding('class.md-sidenav-side')
  bool get modeSide => mode == 'side';

  @HostBinding('class.md-sidenav-over')
  bool get modeOver => mode == 'over';

  @HostBinding('class.md-sidenav-push')
  bool get modePush => mode == 'push';

  /**
   * This is public because we need it from MdSidenavLayout, but it's undocumented and should
   * not be used outside.
   * @internal
   */
  get width {
    if (elementRef.nativeElement) {
      return elementRef.nativeElement.offsetWidth;
    }
    return 0;
  }

  bool _transition = false;
  Future _openFuture;
  Function _openFutureSuccess;
  Function _openFutureError;
  Future _closeFuture;
  Function _closeFutureSuccess;
  Function _closeFutureError;
}

/**
 * <md-sidenav-layout> component.
 *
 * This is the parent component to one or two <md-sidenav>s that validates the state internally
 * and coordinate the backdrop and content styling.
 */
@Component(
    selector: 'md-sidenav-layout',
// Do not use ChangeDetectionStrategy.OnPush. It does not work for this component because
// technically it is a sibling of MdSidenav (on the content tree) and isn't updated when MdSidenav
// changes its state.
    directives: const [MdSidenav],
    templateUrl: 'sidenav.html',
    styleUrls: const ['sidenav.css', 'sidenav-transitions.css'])
class MdSidenavLayout implements AfterContentInit {
  @ContentChildren(MdSidenav)
  QueryList<MdSidenav> sidenavs;

//  set sidenavs(QueryList<MdSidenav> value) {
//    _sidenavs = value;
//  }

//  QueryList<MdSidenav> _sidenavs;

  /** The sidenav at the start/end alignment, independent of direction. */
  MdSidenav _start;
  MdSidenav _end;

  get start => _start;

  get end => _end;

  /**
   * The sidenav at the left/right. When direction changes, these will change as well.
   * They're used as aliases for the above to set the left/right style properly.
   * In LTR, _left == _start and _right == _end.
   * In RTL, _left == _end and _right == _start.
   */
  MdSidenav _left;
  MdSidenav _right;

  Dir _dir;
  ElementRef _elementRef;
  Renderer _renderer;

  MdSidenavLayout(@Optional() this._dir, this._elementRef, this._renderer) {
    if (_dir != null) _dir.dirChange.listen((_) => _validateDrawers());
  }

  /** TODO: internal */
  ngAfterContentInit() {
    // On changes, assert on consistency.
    sidenavs.changes.listen((_) => _validateDrawers());
    sidenavs.forEach((MdSidenav sidenav) => _watchSidenavToggle(sidenav));
    _validateDrawers();
  }

  /*
  * Subscribes to sidenav events in order to set a class on the main layout element when the sidenav
  * is open and the backdrop is visible. This ensures any overflow on the layout element is properly
  * hidden.
  * @internal
  */
  void _watchSidenavToggle(MdSidenav sidenav) {
    if (sidenav == null || sidenav.mode == 'side') return;
    sidenav.onOpen.listen((_) => _setLayoutClass(sidenav, true));
    sidenav.onClose.listen((_) => _setLayoutClass(sidenav, false));
  }

  /* Toggles the 'md-sidenav-opened' class on the main 'md-sidenav-layout' element. */
  void _setLayoutClass(MdSidenav sidenav, bool bool) {
    _renderer.setElementClass(
        _elementRef.nativeElement, 'md-sidenav-opened', bool);
  }

  /** Validate the state of the sidenav children components. */
  void _validateDrawers() {
    _start = null;
    _end = null;

    // Ensure that we have at most one start and one end sidenav.
    sidenavs.forEach((MdSidenav sidenav) {
      if (sidenav.align == 'end') {
        if (_end != null) throw new MdDuplicatedSidenavError('end');
        _end = sidenav;
      } else {
        if (_start != null) throw new MdDuplicatedSidenavError('start');
        _start = sidenav;
      }
    });
    _right = null;
    _left = null;

    // Detect if we're LTR or RTL.
    if (_dir == null || _dir.value == 'ltr') {
      _left = _start;
      _right = _end;
    } else {
      _left = _end;
      _right = _start;
    }
  }

  /** @internal */
  closeModalSidenav() {
    if (_start != null && _start.mode != 'side') {
      _start.close();
    }
    if (_end != null && _end.mode != 'side') {
      _end.close();
    }
  }

  /** @internal */
  bool get isShowingBackdrop {
    return (_isSidenavOpen(_start) && _start.mode != 'side') ||
        (_isSidenavOpen(_end) && _end.mode != 'side');
  }

  bool _isSidenavOpen(MdSidenav side) => side != null && side.opened;

  /**
   * Return the width of the sidenav, if it's in the proper mode and opened.
   * This may relayout the view, so do not call this often.
   * @param sidenav
   * @param mode
   */
  num _getSidenavEffectiveWidth(MdSidenav sidenav, String mode) {
    return (_isSidenavOpen(sidenav) && sidenav.mode == mode)
        ? sidenav.width
        : 0;
  }

  /** @internal */
  num get marginLeft => _getSidenavEffectiveWidth(_left, 'side');

  /** @internal */
  num get marginRight => _getSidenavEffectiveWidth(_right, 'side');

  /** @internal */
  num get positionLeft => _getSidenavEffectiveWidth(_left, 'push');

  /** @internal */
  num get positionRight => _getSidenavEffectiveWidth(_right, 'push');

  /**
   * Returns the horizontal offset for the content area.  There should never be a value for both
   * left and right, so by subtracting the right value from the left value, we should always get
   * the appropriate offset.
   * @internal
   */
  num get positionOffset => positionLeft - positionRight;

  /**
   * This is using [ngStyle] rather than separate [style...] properties because [style.transform]
   * doesn't seem to work right now.
   * @internal
   */
  Map get styles {
    return {
      'marginLeft': '${marginLeft}px',
      'marginRight': '${marginRight}px',
      'transform': 'translate3d($positionOffset}px, 0, 0)'
    };
  }
}

const MD_SIDENAV_DIRECTIVES = const [MdSidenavLayout, MdSidenav];
