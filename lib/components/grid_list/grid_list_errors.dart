import "package:material2_dart/core/errors/error.dart";

/**
 * Exception thrown when cols property is missing from grid-list
 */
class MdGridListColsError extends MdError {
  MdGridListColsError()
      : super(
            'md-grid-list: must pass in number of columns. Example: <md-grid-list cols="3">');
}

/**
 * Exception thrown when a tile's colspan is longer than the number of cols in list
 */
class MdGridTileTooWideError extends MdError {
  MdGridTileTooWideError(num cols, num listLength)
      : super(
            'md-grid-list: tile with colspan $cols is wider than grid with cols="$listLength".');
}

/**
 * Exception thrown when an invalid ratio is passed in as a rowHeight
 */
class MdGridListBadRatioError extends MdError {
  MdGridListBadRatioError(String value)
      : super('md-grid-list: invalid ratio given for row-height: "$value"');
}
