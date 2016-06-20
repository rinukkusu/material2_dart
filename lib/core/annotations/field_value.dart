/// It's enough quite for the alpha phase.
/// FIXME: How to implement @BooleanFieldValue() with ng2 custom annotation or reflectable package?
bool booleanFieldValue(dynamic input) {
  if (input == null) return false;
  if (input is String) {
    if (input == 'false') return false;
    return true;
  }
  if (input is bool) return input;
  throw new ArgumentError();
}
