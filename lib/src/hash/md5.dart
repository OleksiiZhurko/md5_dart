import 'dart:convert';
import 'dart:typed_data';
import 'package:meta/meta.dart';

const int _ZERO = 0;
const int _ONE = 1;
const int _TWO = 2;
const int _THREE = 3;
const int _FOUR = 4;
const int _EIGHT = 8;
const int _SIXTEEN = 16;
const int _TWENTY_FOUR = 24;

const int _BINARY = 2;
const int _HEXADECIMAL = 16;

const int _INT_32 = 32;

const int _BITS_448 = 56;
const int _BITS_512 = 64;

/// Needed to fill the line
const String _AGGREGATE = '0';

const List<int> _k = [
  0, 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
  1, 6, 11,  0,  5, 10, 15,  4,  9, 14,  3,  8, 13,  2,  7, 12,
  5, 8, 11, 14,  1,  4,  7, 10, 13,  0,  3,  6,  9, 12, 15,  2,
  0, 7, 14,  5, 12,  3, 10,  1,  8, 15,  6, 13,  4, 11,  2,  9,
];
const List<int> _s = [
  7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
  5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
  4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
  6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
];
const List<int> _i = [
  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
  48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
];
const List<int> _K = [
  3614090360, 3905402710,  606105819, 3250441966,
  4118548399, 1200080426, 2821735955, 4249261313,
  1770035416, 2336552879, 4294925233, 2304563134,
  1804603682, 4254626195, 2792965006, 1236535329,
  4129170786, 3225465664,  643717713, 3921069994,
  3593408605,   38016083, 3634488961, 3889429448,
  568446438, 3275163606, 4107603335, 1163531501,
  2850285829, 4243563512, 1735328473, 2368359562,
  4294588738, 2272392833, 1839030562, 4259657740,
  2763975236, 1272893353, 4139469664, 3200236656,
  681279174, 3936430074, 3572445317,   76029189,
  3654602809, 3873151461,  530742520, 3299628645,
  4096336452, 1126891415, 2878612391, 4237533241,
  1700485571, 2399980690, 4293915773, 2240044497,
  1873313359, 4264355552, 2734768916, 1309151649,
  4149444226, 3174756917,  718787259, 3951481745,
];

const List<Function> _functions = [_funcF, _funcG, _funcH, _funcI];

/// The first [F] calculation function [MD5]
///
/// Formula (X and Y) or (not_X and Z)
///
/// Returns a computed [int]
int _funcF(int x, int y, int z) => (x & y) | (~x & z);

/// The second [G] calculation function [MD5]
///
/// Formula (X and Z) or (not_Z and Y)
///
/// Returns a computed [int]
int _funcG(int x, int y, int z) => (x & z) | (~z & y);

/// The third [H] calculation function [MD5]
///
/// Formula X xor Y xor Z
///
/// Returns a computed [int]
int _funcH(int x, int y, int z) => x ^ y ^ z;

/// The fourth [I] calculation function [MD5]
///
/// Formula Y xor (not_Z or X)
///
/// Returns a computed [int]
int _funcI(int x, int y, int z) => y ^ (~z | x);


/// The main facade method
///
/// Returns a [String] of the input array in hex hash representation
String getHash(String s) {
  var bytes = <int>[];

  bytes.addAll(utf8.encode(s));

  var bytesSize = bytes.length;

  bytes = align(bytes);
  bytes.addAll(_appendLittleEndian(bytes, bytesSize * _EIGHT));

  return _produceHash(_bytesToUintArr(bytes));
}

/// Bytes alignment according to MD5 requirements
///
/// Returns an aligned string
@visibleForTesting
List<int> align(List<int> bytes) {
  bytes.add(128); // 0b10000000

  while (bytes.length % _BITS_512 != _BITS_448) {
    bytes.add(0);
  }

  return bytes;
}

/// Shrinking the bytes by 4
///
/// Returns a compressed [Uint32List] of integers
List<int> _bytesToUintArr(List<int> bytes) {
  var list = Uint32List(bytes.length ~/ _FOUR);

  for (var one = 0, two = 0; one < bytes.length; one += 4, two += 1) {
    list[two]  = ((bytes[one +  _ZERO]) << _ZERO).toUnsigned(_INT_32);
    list[two] += ((bytes[one +   _ONE]) << _EIGHT).toUnsigned(_INT_32);
    list[two] += ((bytes[one +   _TWO]) << _SIXTEEN).toUnsigned(_INT_32);
    list[two] += ((bytes[one + _THREE]) << _TWENTY_FOUR).toUnsigned(_INT_32);
  }

  return list;
}

/// The main hash calculate method
///
/// Returns a [String] of the input array in hex hash representation
String _produceHash(List<int> bytes) {
  int aa, bb, cc, dd, i;

  var a = 1732584193;
  var b = 4023233417;
  var c = 2562383102;
  var d =  271733878;

  for (var one = 0; one < bytes.length; one += 16) {
    i = 0;
    aa = a;
    bb = b;
    cc = c;
    dd = d;

    for (var two = 0; two < _FOUR; two++) {
      for (var three = 0; three < _FOUR; three++) {
        a = b + rotateLeftInt(
            (a + _functions[two](b, c, d) + bytes[one + _k[i]] + _K[i])
                .toInt().toUnsigned(_INT_32),
            _s[i++]);
        d = a + rotateLeftInt(
            (d + _functions[two](a, b, c) + bytes[one + _k[i]] + _K[i])
                .toInt().toUnsigned(_INT_32),
            _s[i++]);
        c = d + rotateLeftInt(
            (c + _functions[two](d, a, b) + bytes[one + _k[i]] + _K[i])
                .toInt().toUnsigned(_INT_32),
            _s[i++]);
        b = c + rotateLeftInt(
            (b + _functions[two](c, d, a) + bytes[one + _k[i]] + _K[i])
                .toInt().toUnsigned(_INT_32),
            _s[i++]);
      }
    }

    a = (a + aa).toUnsigned(_INT_32);
    b = (b + bb).toUnsigned(_INT_32);
    c = (c + cc).toUnsigned(_INT_32);
    d = (d + dd).toUnsigned(_INT_32);
  }

  return _produceLittleEndianMD5Answer(a, b, c, d);
}

/// Represents value in [Endian.little]
///
/// Returns a [String] of the number in hexadecimal
@visibleForTesting
String produceLittleEndianUint32Hex(int n) =>
    (ByteData(_INT_32)..setUint32(0, n))
        .getUint32(0, Endian.little).toRadixString(_HEXADECIMAL);

/// Aligns a hex string to 8 chars
///
/// Returns an aligned hex string
@visibleForTesting
String alignHexIn8(String hex, [int len = _EIGHT]) =>
    _AGGREGATE * (len - hex.length) + hex;

/// Performs a cyclic left shift
///
/// Returns the shifted [int]
@visibleForTesting
int rotateLeftInt(int n, int shift, [int intNum = _INT_32]) =>
    (n << (shift % intNum)).toUnsigned(intNum) |
    (n >> (intNum - (shift % intNum)).toUnsigned(intNum));

/// Represents value in [Endian.little]
///
/// Returns a [String] of collected integers
String _produceLittleEndianMD5Answer(int a, int b, int c, int d) =>
    alignHexIn8(produceLittleEndianUint32Hex(a)) +
        alignHexIn8(produceLittleEndianUint32Hex(b)) +
        alignHexIn8(produceLittleEndianUint32Hex(c)) +
        alignHexIn8(produceLittleEndianUint32Hex(d));

/// Converts a number to an array of bytes in [Endian.little] representation
///
/// Returns an [Uint8List] in [Endian.little] representation
List<int> _appendLittleEndian(List<int> bytes, int n) =>
  Uint8List(_EIGHT)..buffer.asByteData().setInt64(0, n, Endian.little);

