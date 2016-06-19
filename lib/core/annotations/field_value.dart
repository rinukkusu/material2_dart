/// It's enough quite for the alpha phase.
/// FIXME: How to implement @BooleanFieldValue() with ng2 custom annotation or reflectable package?
bool booleanFieldValue(String input) {
  if (input == null || input == 'false') return false;
  return true;
}
