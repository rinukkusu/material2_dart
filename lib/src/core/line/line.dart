import 'dart:html';
import "package:angular2/core.dart";

/**
 * Shared directive to count lines inside a text area, such as a list item.
 * Line elements can be extracted with a @ContentChildren(MdLine) query, then
 * counted by checking the query list's length.
 */
@Directive(selector: "[md-line]")
class MdLine {}

/* Helper that takes a query list of lines and sets the correct class on the host */
class MdLineSetter {
  QueryList<MdLine> lines;
  ElementRef _elementRef;
  Element get _nativeElement => _elementRef.nativeElement;
  MdLineSetter(this.lines, this._elementRef) {
    _setLineClass(lines.length);
    lines.changes.listen((_) {
      _setLineClass(lines.length);
    });
  }

  void _setLineClass(num count) {
    _resetClasses();
    if (identical(count, 2) || identical(count, 3)) {
      _nativeElement.classes.add('md-$count-line');
    }
  }

  void _resetClasses() {
    _nativeElement.classes..remove('md-2-line')..remove('md-3-line');
  }
}
