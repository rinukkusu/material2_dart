bool booleanFieldValue(dynamic input) {
  if (input == null) return false;
  if (input is bool) return input;
  if (input is String) {
    if (input == 'false') return false;
    return true;
  }
  throw new ArgumentError.value(input);
}
