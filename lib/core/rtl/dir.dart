import 'package:angular2/core.dart';

/**
 * Directive to listen to changes of direction of part of the DOM.
 *
 * Applications should use this directive instead of the native attribute so that Material
 * components can listen on changes of direction.
 */
@Directive(
    selector: '[dir]',
// TODO(hansl): maybe `$implicit` isn't the best option here, but for now that's the best we got.
// TODO(me): What's this? (delete this before commit.)
    exportAs: r'$implicit')
class Dir {
  // Because Dart doesn't have Union Types.
  final List<String> _layoutDirections = const ['ltr', 'rtl'];

  @Input('dir')
  String _dir = 'ltr';

  @Output()
  EventEmitter dirChange = new EventEmitter();

  @HostBinding('attr.dir')
  String get dir => _dir;

  void set dir(String v) {
    if (!_layoutDirections.contains(v)) {
      throw new StateError('Invalid dir value.');
    }
    var old = _dir;
    _dir = v;
    if (old != _dir) dirChange.emit(null);
  }

  String get value => dir;

  void set value(String v) {
    dir = v;
  }
}
