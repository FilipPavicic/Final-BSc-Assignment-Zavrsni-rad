import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recognizing_text2/Utils.dart';

void main() {
  test('Test adjustOneAndASCII', () {
    String teststr1 = "Pavičić";
    expect(teststr1, isNot(equals(adjustOneAndASCII(teststr1,aciiNamerules))));
    expect("pavicic", adjustOneAndASCII(teststr1,aciiNamerules));
    expect("ooo", adjustOneAndASCII("000",aciiNamerules));
  });
  test('Test adjustElemsAndASCII', () {
    expect(['pavicic', 'ooo'], adjustElemsAndASCII(['Pavičić', 'oo0']));
  });
}
