/// [input]'s type is expected as num | String union type.
/// Nullable.
num numFieldValue(dynamic input) {
  if (input == null) return null;
  if (input is num) return input;
  if (input is String) return num.parse(input);
  throw new ArgumentError.value(input);
}

/// [input]'s type is expected as int | String union type.
/// Nullable.
int intFieldValue(dynamic input) {
  if (input == null) return null;
  if (input is int) return input;
  if (input is String) return int.parse(input);
  throw new ArgumentError.value(input);
}
