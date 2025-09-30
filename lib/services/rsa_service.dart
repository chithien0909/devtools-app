
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:pointycastle/asymmetric/api.dart';

class RsaService {
  const RsaService();

  Future<String> encrypt(String text, String publicKeyString) async {
    if (text.isEmpty) {
      return '';
    }
    final parser = encrypt_lib.RSAKeyParser();
    final publicKey = parser.parse(publicKeyString) as RSAPublicKey;
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.RSA(publicKey: publicKey));
    final encrypted = encrypter.encrypt(text);
    return encrypted.base64;
  }

  Future<String> decrypt(String text, String privateKeyString) async {
    if (text.isEmpty) {
      return '';
    }
    final parser = encrypt_lib.RSAKeyParser();
    final privateKey = parser.parse(privateKeyString) as RSAPrivateKey;
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.RSA(privateKey: privateKey));
    try {
      final decrypted = encrypter.decrypt64(text);
      return decrypted;
    } on Exception {
      throw const FormatException('Input is not valid RSA.');
    }
  }
}
