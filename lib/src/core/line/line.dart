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
  Renderer _renderer;
  ElementRef _elementRef;

  MdLineSetter(this.lines, this._renderer, this._elementRef) {
    _setLineClass(lines.length);
    lines.changes.listen((_) {
      _setLineClass(lines.length);
    });
  }

  void _setLineClass(num count) {
    _resetClasses();
    if (identical(count, 2) || identical(count, 3)) {
      _setClass('md-$count-line', true);
    }
  }

  void _resetClasses() {
    _setClass("md-2-line", false);
    _setClass("md-3-line", false);
  }

  void _setClass(String className, bool bool) {
    _renderer.setElementClass(_elementRef.nativeElement, className, bool);
  }
}
