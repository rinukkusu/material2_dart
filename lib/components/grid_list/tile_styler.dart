import "grid_tile.dart";
import "tile_coordinator.dart";
import "grid_list_errors.dart";

/* Sets the style properties for an individual tile, given the position calculated by the
* Tile Coordinator. */
class TileStyler {
  String _gutterSize;
  int _rows = 0;
  int _rowspan = 0;
  int _cols;
  String _direction;

  /** Adds grid-list layout info once it is available. Cannot be processed in the constructor
   * because these properties haven't been calculated by that point.
   * @internal
   * */
  void init(
      String _gutterSize, TileCoordinator tracker, int cols, String direction) {
    this._gutterSize = normalizeUnits(_gutterSize);
    _rows = tracker.rowCount;
    _rowspan = tracker.rowspan;
    _cols = cols;
    _direction = direction;
  }

  /**
   * Computes the amount of space a single 1x1 tile would take up (width or height).
   * Used as a basis for other calculations.
   * @internal
   * @param sizePercent Percent of the total grid-list space that one 1x1 tile would take up.
   * @param gutterFraction Fraction of the gutter size taken up by one 1x1 tile.
   * @return The size of a 1x1 tile as an expression that can be evaluated via CSS calc().
   */
  String getBaseTileSize(num sizePercent, num gutterFraction) {
    // Take the base size percent (as would be if evenly dividing the size between cells),
    // and then subtracting the size of one gutter. However, since there are no gutters on the
    // edges, each tile only uses a fraction (gutterShare = numGutters / numCells) of the gutter
    // size. (Imagine having one gutter per tile, and then breaking up the extra gutter on the
    // edge evenly among the cells).
    return '($sizePercent% - ($_gutterSize * $gutterFraction))';
  }

  /**
   * Gets The horizontal or vertical position of a tile, e.g., the 'top' or 'left' property value.
   * @internal
   * @param offset Number of tiles that have already been rendered in the row/column.
   * @param baseSize Base size of a 1x1 tile (as computed in getBaseTileSize).
   * @return Position of the tile as a CSS calc() expression.
   */
  String getTilePosition(String baseSize, int offset) {
    // The position comes the size of a 1x1 tile plus gutter for each previous tile in the
    // row/column (offset).
    return calc('($baseSize + $_gutterSize) * $offset');
  }

  /**
   * Gets the actual size of a tile, e.g., width or height, taking rowspan or colspan into account.
   * @internal
   * @param baseSize Base size of a 1x1 tile (as computed in getBaseTileSize).
   * @param span The tile's rowspan or colspan.
   * @return Size of the tile as a CSS calc() expression.
   */
  String getTileSize(String baseSize, num span) {
    return '($baseSize * $span) + (${span - 1} * $_gutterSize)';
  }

  /** Gets the style properties to be applied to a tile for the given row and column index.
   * @internal
   */
  void setStyle(MdGridTile tile, int rowIndex, int colIndex) {
    // Percent of the available horizontal space that one column takes up.
    num percentWidthPerTile = 100 / _cols;
    // Fraction of the vertical gutter size that each column takes up.
    // For example, if there are 5 columns, each column uses 4/5 = 0.8 times the gutter width.
    num gutterWidthFractionPerTile = (_cols - 1) / _cols;
    setColStyles(
        tile, colIndex, percentWidthPerTile, gutterWidthFractionPerTile);
    setRowStyles(
        tile, rowIndex, percentWidthPerTile, gutterWidthFractionPerTile);
  }

  /** Sets the horizontal placement of the tile in the list.
   * @internal
   */
  void setColStyles(
      MdGridTile tile, int colIndex, num percentWidth, num gutterWidth) {
    // Base horizontal size of a column.
    String baseTileWidth = getBaseTileSize(percentWidth, gutterWidth);
    // The width and horizontal position of each tile is always calculated the same way, but the
    // height and vertical position depends on the rowMode.
    String side = identical(_direction, "ltr") ? "left" : "right";
    tile.setStyle(side, getTilePosition(baseTileWidth, colIndex));
    tile.setStyle("width", calc(getTileSize(baseTileWidth, tile.colspan)));
  }

  /** Calculates the total size taken up by gutters across one axis of a list.
   * @internal
   */
  String getGutterSpan() {
    return '$_gutterSize * ($_rowspan - 1)';
  }

  /** Calculates the total size taken up by tiles across one axis of a list.
   * @internal
   */
  String getTileSpan(String tileHeight) {
    return '$_rowspan * ${getTileSize(tileHeight, 1)}';
  }

  /** Sets the vertical placement of the tile in the list.
   * This method will be implemented by each type of TileStyler.
   * @internal
   */
  void setRowStyles(
      MdGridTile tile, int rowIndex, num percentWidth, num gutterWidth) {}

  /** Calculates the computed height and returns the correct style property to set.
   * This method will be implemented by each type of TileStyler.
   * @internal
   */
  List<String> getComputedHeight() {
    return null;
  }
}

/*  This type of styler is instantiated when the user passes in a fixed row height
*   Example <md-grid-list cols="3" rowHeight="100px"> */
class FixedTileStyler extends TileStyler {
  String fixedRowHeight;

  FixedTileStyler(this.fixedRowHeight) : super();

  // @internal
  @override
  void init(String gutterSize, TileCoordinator tracker, int cols, String direction) {
    super.init(gutterSize, tracker, cols, direction);
    fixedRowHeight = normalizeUnits(fixedRowHeight);
  }

  // @internal
  @override
  void setRowStyles(
      MdGridTile tile, int rowIndex, num percentWidth, num gutterWidth) {
    tile.setStyle("top", getTilePosition(fixedRowHeight, rowIndex));
    tile.setStyle("height", calc(getTileSize(fixedRowHeight, tile.rowspan)));
  }

  // @internal
  @override
  List<String> getComputedHeight() {
    return [
      "height",
      calc('${getTileSpan(fixedRowHeight)} + ${getGutterSpan()}')
    ];
  }
}

/*  This type of styler is instantiated when the user passes in a width:height ratio
 *  for the row height.  Example <md-grid-list cols="3" rowHeight="3:1"> */
class RatioTileStyler extends TileStyler {
  /** Ratio width:height given by user to determine row height.*/
  num rowHeightRatio;
  String baseTileHeight;

  RatioTileStyler(String value) : super() {
    _parseRatio(value);
  }

  // @internal
  @override
  void setRowStyles(
      MdGridTile tile, int rowIndex, num percentWidth, num gutterWidth) {
    var percentHeightPerTile = percentWidth / rowHeightRatio;
    baseTileHeight = getBaseTileSize(percentHeightPerTile, gutterWidth);
    // Use paddingTop and marginTop to maintain the given aspect ratio, as
    // a percentage-based value for these properties is applied versus the *width* of the
    // containing block. See http://www.w3.org/TR/CSS2/box.html#margin-properties
    tile.setStyle("marginTop", getTilePosition(baseTileHeight, rowIndex));
    tile.setStyle(
        "paddingTop", calc(getTileSize(baseTileHeight, tile.rowspan)));
  }

  // @internal
  @override
  List<String> getComputedHeight() {
    return [
      "paddingBottom",
      calc('${getTileSpan(baseTileHeight)} + ${getGutterSpan()}')
    ];
  }

  /** @internal */
  void _parseRatio(String value) {
    List<String> ratioParts = value.split(":");
    if (ratioParts.length != 2) {
      throw new MdGridListBadRatioError(value);
    }
    rowHeightRatio = num.parse(ratioParts[0]) / num.parse(ratioParts[1]);
  }
}

/*  This type of styler is instantiated when the user selects a "fit" row height mode.
 *  In other words, the row height will reflect the total height of the container divided
 *  by the number of rows.  Example <md-grid-list cols="3" rowHeight="fit"> */
class FitTileStyler extends TileStyler {
  // @internal
  @override
  void setRowStyles(
      MdGridTile tile, int rowIndex, num percentWidth, num gutterWidth) {
    // Percent of the available vertical space that one row takes up.
    var percentHeightPerTile = 100 / _rowspan;
    // Fraction of the horizontal gutter size that each column takes up.
    var gutterHeightPerTile = (_rows - 1) / _rows;
    // Base vertical size of a column.
    var baseTileHeight =
        getBaseTileSize(percentHeightPerTile, gutterHeightPerTile);
    tile.setStyle("top", getTilePosition(baseTileHeight, rowIndex));
    tile.setStyle("height", calc(getTileSize(baseTileHeight, tile.rowspan)));
  }
}

/** Wraps a CSS string in a calc function
 * @internal
 */
String calc(String exp) => 'calc($exp)';

/** Appends pixels to a CSS string if no units are given.
 * @internal
 */
String normalizeUnits(String value) {
  return value.contains(new RegExp(r'px|em|rem')) ? value : value + "px";
}
