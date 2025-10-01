import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashService {
  String generate(String input, String algorithm) {
    final bytes = utf8.encode(input);
    Digest digest;

    switch (algorithm) {
      case 'md5':
        digest = md5.convert(bytes);
        break;
      case 'sha1':
        digest = sha1.convert(bytes);
        break;
      case 'sha256':
        digest = sha256.convert(bytes);
        break;
      default:
        return 'Invalid algorithm';
    }

    return digest.toString();
  }
}
