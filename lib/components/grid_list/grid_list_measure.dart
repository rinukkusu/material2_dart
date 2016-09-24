/// Converts values into strings. Falsy values become empty strings.
String coerceToString(dynamic /* String | num */ value) {
  if (value is String) return value;
  if (value is num) return (value.toInt() == 0) ? "" : value.toString();
  throw new ArgumentError();
}

/// Converts a value that might be a string into a number.
num coerceToNumber(dynamic /* String | num */ value) {
  if (value is num) return value;
  if (value is String) return num.parse(value);
  throw new ArgumentError();
}
