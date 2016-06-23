import 'dart:math' as math;
import "grid_tile.dart";
import "grid_list_errors.dart";

/**
 * Class for determining, from a list of tiles, the (row, col) position of each of those tiles
 * in the grid. This is necessary (rather than just rendering the tiles in normal document flow)
 * because the tiles can have a rowspan.
 *
 * The positioning algorithm greedily places each tile as soon as it encounters a gap in the grid
 * large enough to accommodate it so that the tiles still render in the same order in which they
 * are given.
 *
 * The basis of the algorithm is the use of an array to track the already placed tiles. Each
 * element of the array corresponds to a column, and the value indicates how many cells in that
 * column are already occupied; zero indicates an empty cell. Moving "down" to the next row
 * decrements each value in the tracking array (indicating that the column is one cell closer to
 * being free).
 */
class TileCoordinator {
  /** Tracking array (see class description). */
  List<int> tracker;

  /** Index at which the search for the next gap will start. */
  int columnIndex = 0;

  /** The current row index. */
  int rowIndex = 0;

  /** Gets the total number of rows occupied by tiles */
  int get rowCount => rowIndex + 1;

  /** Gets the total span of rows occupied by tiles.
   * Ex: A list with 1 row that contains a tile with rowspan 2 will have a total rowspan of 2. */
  int get rowspan {
    int lastRowMax = tracker.reduce(math.max);
    // if any of the tiles has a rowspan that pushes it beyond the total row count,
    // add the difference to the rowcount
    return lastRowMax > 1 ? rowCount + lastRowMax - 1 : rowCount;
  }

  /** The computed (row, col) position of each tile (the output). */
  List<TilePosition> positions;

  TileCoordinator(int numColumns, List<MdGridTile> tiles)
      : tracker = new List.filled(numColumns, 0) {
    positions = tiles.map((tile) => _trackTile(tile)).toList();
  }

  /** Calculates the row and col position of a tile. */
  TilePosition _trackTile(MdGridTile tile) {
    // Find a gap large enough for this tile.
    var gapStartIndex = _findMatchingGap(tile.colspan);
    // Place tile in the resulting gap.
    _markTilePosition(gapStartIndex, tile);
    // The next time we look for a gap, the search will start at columnIndex, which should be

    // immediately after the tile that has just been placed.
    columnIndex = gapStartIndex + tile.colspan;
    return new TilePosition(rowIndex, gapStartIndex);
  }

  /** Finds the next available space large enough to fit the tile. */
  int _findMatchingGap(num tileCols) {
    if (tileCols > tracker.length) {
      throw new MdGridTileTooWideError(tileCols, tracker.length);
    }
    // Start index is inclusive, end index is exclusive.
    int gapStartIndex = -1;
    int gapEndIndex = -1;
    // Look for a gap large enough to fit the given tile. Empty spaces are marked with a zero.
    do {
      // If we've reached the end of the row, go to the next row.
      if (columnIndex + tileCols > tracker.length) {
        _nextRow();
        continue;
      }
      gapStartIndex = tracker.indexOf(0, columnIndex);
      // If there are no more empty spaces in this row at all, move on to the next row.
      if (gapStartIndex == -1) {
        _nextRow();
        continue;
      }
      gapEndIndex = _findGapEndIndex(gapStartIndex);
      // If a gap large enough isn't found, we want to start looking immediately after the current

      // gap on the next iteration.
      columnIndex = gapStartIndex + 1;
    } while (gapEndIndex - gapStartIndex < tileCols);
    return gapStartIndex;
  }

  /** Move "down" to the next row. */
  void _nextRow() {
    columnIndex = 0;
    rowIndex++;
    // Decrement all spaces by one to reflect moving down one row.
    for (var i = 0; i < tracker.length; i++) {
      tracker[i] = math.max(0, tracker[i] - 1);
    }
  }

  /**
   * Finds the end index (exclusive) of a gap given the index from which to start looking.
   * The gap ends when a non-zero value is found.
   */
  num _findGapEndIndex(num gapStartIndex) {
    for (int i = gapStartIndex + 1; i < tracker.length; i++) {
      if (tracker[i] != 0) return i;
    }
    // The gap ends with the end of the row.
    return tracker.length;
  }

  /** Update the tile tracker to account for the given tile in the given space. */
  void _markTilePosition(num start, MdGridTile tile) {
    for (int i = 0; i < tile.colspan; i++) {
      tracker[start + i] = tile.rowspan;
    }
  }
}

/** Simple data structure for tile position (row, col).
 * @internal
 */
class TilePosition {
  int row;
  int col;

  TilePosition(this.row, this.col);
}
