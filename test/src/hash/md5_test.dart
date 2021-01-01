import 'dart:convert';
import 'package:MD5/src/hash/md5.dart' as MD5;
import 'package:test/test.dart';

/// Test MD5 class
void main() {
  group('align(p1)', () {
    test('Len 0', () {
      expect(
          MD5.align(List.of(utf8.encode(''))).length,
          56
      );
    });
    test('Len 1', () {
      expect(
          MD5.align(List.of(utf8.encode('1'))).length,
          56
      );
    });
    test('Len 55', () {
      expect(
          MD5.align(List.of(utf8.encode(
              'text for testing text for testing text for testing text'))).length,
          56
      );
    });
    test('Len 56', () {
      expect(
          MD5.align(List.of(utf8.encode(
              'text for testing text for testing text for testing text '))).length,
          120
      );
    });
  });

  group('produceLittleEndianHex(p1)', () {
    test('Case 1', () {
      expect(
          MD5.produceLittleEndianUint32Hex(10),
          'a000000'
      );
    });
    test('Case 2', () {
      expect(
          MD5.produceLittleEndianUint32Hex(555),
          '2b020000'
      );
    });
    test('Case 3', () {
      expect(
          MD5.produceLittleEndianUint32Hex(2048),
          '80000'
      );
    });
  });

  group('alignHexIn8(p1)', () {
    test('Case 1', () {
      expect(
          MD5.alignHexIn8('10').length,
          8
      );
    });
    test('Case 2', () {
      expect(
          MD5.alignHexIn8('').length,
          8
      );
    });
    test('Case 3', () {
      expect(
          MD5.alignHexIn8('42638636').length,
          8
      );
    });
    test('Case 4', () {
      expect(
          MD5.alignHexIn8('1234567890').length,
          10
      );
    });
  });

  group('rotateLeftInt32(p1, p2)', () {
    test('Case 1', () {
      expect(
          MD5.rotateLeftInt(4, 2).toRadixString(2),
          '10000'
      );
    });
    test('Case 2', () {
      expect(
          MD5.rotateLeftInt(65535, 31).toRadixString(2),
          '10000000000000000111111111111111'
      );
    });
    test('Case 3', () {
      expect(
          MD5.rotateLeftInt(65535, 33).toRadixString(2),
          '11111111111111110'
      );
    });
    test('Case 4', () {
      expect(
          MD5.rotateLeftInt(65535, 0).toRadixString(2),
          '1111111111111111'
      );
    });
    test('Case 5', () { // like rotate right
      expect(
          MD5.rotateLeftInt(65535, -1).toRadixString(2),
          '10000000000000000111111111111111'
      );
    });
  });

  group('getHash(p1)', () {
    test('Classic 1', () {
      expect(
          MD5.getHash('Hello World'),
          'b10a8db164e0754105b7a99be72e3fe5'
      );
    });
    test('Classic 2', () {
      expect(
          MD5.getHash('MD5'),
          '7f138a09169b250e9dcb378140907378'
      );
    });
    test('Cyrillic symbols', () {
      expect(
          MD5.getHash('пароль'),
          'e242f36f4f95f12966da8fa2efd59992'
      );
    });
    test('Long string', () {
      expect(
          MD5.getHash('Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
              'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
          '818c6e601a24f72750da0f6c9b8ebe28');
    });
    test('Empty string', () {
      expect(
          MD5.getHash(''),
          'd41d8cd98f00b204e9800998ecf8427e'
      );
    });
    test('Special symbols', () {
      expect(
          MD5.getHash('¼½¾'),
          '61007c78e698ff51dc47470b337a4b8c'
      );
    });
  });
}
