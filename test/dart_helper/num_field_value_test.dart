import 'package:test/test.dart';
import 'package:material2_dart/material.dart';

void main() {
  test('numFieldValue', () {
    Null nullValue;
    expect(numFieldValue(nullValue), isNull);
    num numValue = 1;
    expect(numFieldValue(numValue), numValue);
    int intValue = 1;
    expect(numFieldValue(intValue), intValue);
    double doubleValue = 1.1;
    expect(numFieldValue(doubleValue), doubleValue);
    String numParsableStringValue = '1';
    expect(numFieldValue(numParsableStringValue), 1);
    String numParsableStringValue2 = '1.1';
    expect(numFieldValue(numParsableStringValue2), 1.1);
    String stringValue = 'a';
    expect(() => numFieldValue(stringValue), throwsFormatException);
    bool otherTypedValue = true;
    expect(() => numFieldValue(otherTypedValue), throwsArgumentError);
  });
  test('intFieldValue', () {
    Null nullValue;
    expect(intFieldValue(nullValue), isNull);
    num numValue = 1;
    expect(intFieldValue(numValue), numValue);
    int intValue = 1;
    expect(intFieldValue(intValue), intValue);
    double doubleValue = 1.1;
    expect(() => intFieldValue(doubleValue), throwsArgumentError);
    String numParsableStringValue = '1';
    expect(intFieldValue(numParsableStringValue), 1);
    String numParsableStringValue2 = '1.1';
    expect(() => intFieldValue(numParsableStringValue2), throwsFormatException);
    String stringValue = 'a';
    expect(() => intFieldValue(stringValue), throwsFormatException);
    bool otherTypedValue = true;
    expect(() => intFieldValue(otherTypedValue), throwsArgumentError);
  });
}
