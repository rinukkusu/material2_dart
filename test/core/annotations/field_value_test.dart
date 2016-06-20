import 'package:test/test.dart';
import 'package:material2_dart/core/annotations/field_value.dart';

void main() {
  group('BooleanFieldValue', () {
    test('should work for null value', () {
      expect(booleanFieldValue(null), isFalse);
    });
    test('should work for String values', () {
      expect(booleanFieldValue('hello'), isTrue);
      expect(booleanFieldValue('true'), isTrue);
      expect(booleanFieldValue(''), isTrue);
      expect(booleanFieldValue('false'), isFalse);
    });
    test('should work for bool value', () {
      expect(booleanFieldValue(true), isTrue);
      expect(booleanFieldValue(false), isFalse);
    });
  });
}
