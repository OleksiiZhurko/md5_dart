import 'dart:convert';
import 'dart:io';
import 'package:MD5/src/hash/md5.dart' as MD5;

/// Control class
class Command {
  /// Interacts with the user
  void call() {
    String s;

    while ((s = _enterCommand()) != '\\exit') {
      if (s.startsWith('\\path ')) {
        try {
          _printOutput(MD5.getHash(base64.encode(
              File(s.substring(s.lastIndexOf(' ') + 1)).readAsBytesSync())));
        } on FileSystemException {
          _printOutput('The given file does not exists');
        }
      } else {
        _printOutput(MD5.getHash(s));
      }
    }
  }

  /// Returns a string entered by the user
  String _enterCommand() {
    _printer();
    return stdin.readLineSync();
  }

  void _printer([String s = '', String symbol = '\$']) =>
      stdout.write('$symbol$s');

  void _printOutput(String s) => _printer('$s\n', '>');
}
