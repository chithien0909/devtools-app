import 'dart:convert';

import 'package:crypto/crypto.dart';

class HashService {
  const HashService();

  Future<String> md5Hash(String input) async {
    if (input.isEmpty) {
      return '';
    }
    return md5.convert(utf8.encode(input)).toString();
  }

  Future<String> sha1Hash(String input) async {
    if (input.isEmpty) {
      return '';
    }
    return sha1.convert(utf8.encode(input)).toString();
  }

  Future<String> sha256Hash(String input) async {
    if (input.isEmpty) {
      return '';
    }
    return sha256.convert(utf8.encode(input)).toString();
  }
}
