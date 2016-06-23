/**
 * Converts values into strings. Falsy values become empty strings.
 * @internal
 */
String coerceToString(dynamic /* String | num */ value) {
  if (value is num) return (value.toInt() == 0) ? "" : value.toString();
  return value;
}

/**
 * Converts a value that might be a string into a number.
 * @internal
 */
int coerceToNumber(dynamic /* String | num */ value) {
  if (value is String) return num.parse(value).toInt();
  num v = value;
  return v.toInt();
}
