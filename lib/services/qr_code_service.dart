import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeService {
  Widget generate(String data) {
    return QrImageView(data: data, version: QrVersions.auto, size: 200.0);
  }
}
