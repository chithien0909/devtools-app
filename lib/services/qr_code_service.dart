
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeService {
  const QrCodeService();

  Future<String> generate(String data) async {
    if (data.isEmpty) {
      return '';
    }
    return data;
  }

  Future<String> scan() async {
    return 'QR scanning coming soon.';
  }
}
