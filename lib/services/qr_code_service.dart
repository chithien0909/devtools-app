class QrCodeService {
  const QrCodeService();

  Future<String> generate(String data) async {
    final trimmed = data.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Enter text to convert into a QR code.');
    }
    return trimmed;
  }
}
