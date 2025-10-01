import 'dart:convert';

class Base64Service {
  String encode(String input) {
    return base64.encode(utf8.encode(input));
  }

  String decode(String input) {
    return utf8.decode(base64.decode(input));
  }
}
