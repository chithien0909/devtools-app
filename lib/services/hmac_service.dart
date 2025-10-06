import 'dart:convert';
import 'package:crypto/crypto.dart';

class HmacService {
  const HmacService();

  String generate({
    required String message,
    required String secret,
    String algorithm = 'sha256',
    String output = 'hex',
  }) {
    final key = utf8.encode(secret);
    final data = utf8.encode(message);

    Hmac hmac;
    switch (algorithm.toLowerCase()) {
      case 'sha1':
        hmac = Hmac(sha1, key);
        break;
      case 'sha256':
        hmac = Hmac(sha256, key);
        break;
      case 'sha512':
        hmac = Hmac(sha512, key);
        break;
      default:
        throw ArgumentError('Unsupported algorithm: $algorithm');
    }

    final digest = hmac.convert(data);
    return output.toLowerCase() == 'base64'
        ? base64.encode(digest.bytes)
        : digest.toString();
  }
}
