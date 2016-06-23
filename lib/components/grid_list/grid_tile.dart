import "package:angular2/core.dart";
import "package:material2_dart/core/line/line.dart";
import "grid_list_measure.dart";

@Component(
    selector: "md-grid-tile",
    host: const {"role": "listitem"},
    templateUrl: "grid_tile.html",
    styleUrls: const ["grid_list.css"],
    encapsulation: ViewEncapsulation.None)
class MdGridTile {
  Renderer _renderer;
  ElementRef _elementRef;
  int _rowspan = 1;
  int _colspan = 1;

  MdGridTile(this._renderer, this._elementRef);

  int get rowspan => _rowspan;

  int get colspan => _colspan;

  @Input()
  set rowspan(value) {
    _rowspan = coerceToNumber(value);
  }

  @Input()
  set colspan(value) {
    _colspan = coerceToNumber(value);
  }

  /** Sets the style of the grid-tile element.  Needs to be set manually to avoid
   * "Changed after checked" errors that would occur with HostBinding.
   * @internal
   */
  void setStyle(String property, String value) {
    _renderer.setElementStyle(_elementRef.nativeElement, property, value);
  }
}

@Component(
    selector: "md-grid-tile-header, md-grid-tile-footer",
    templateUrl: "grid_tile_text.html")
class MdGridTileText implements AfterContentInit {
  Renderer _renderer;
  ElementRef _elementRef;

  /**
   *  Helper that watches the number of lines in a text area and sets
   * a class on the host element that matches the line count.
   */
  MdLineSetter _lineSetter;
  @ContentChildren(MdLine)
  QueryList<MdLine> lines;

  MdGridTileText(this._renderer, this._elementRef) {}

  ngAfterContentInit() {
    _lineSetter = new MdLineSetter(lines, _renderer, _elementRef);
  }
}
