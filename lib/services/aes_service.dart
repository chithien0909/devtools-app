
import 'package:encrypt/encrypt.dart';

class AesService {
  const AesService();

  Future<String> encrypt(String text, String keyString) async {
    if (text.isEmpty) {
      return '';
    }
    final key = Key.fromUtf8(keyString);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted.base64;
  }

  Future<String> decrypt(String text, String keyString) async {
    if (text.isEmpty) {
      return '';
    }
    final key = Key.fromUtf8(keyString);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    try {
      final decrypted = encrypter.decrypt64(text, iv: iv);
      return decrypted;
    } on Exception {
      throw const FormatException('Input is not valid AES.');
    }
  }
}
