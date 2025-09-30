class UrlCodecService {
  const UrlCodecService();

  Future<String> encode(String input) async {
    if (input.isEmpty) {
      return '';
    }
    return Uri.encodeComponent(input);
  }

  Future<String> decode(String input) async {
    if (input.isEmpty) {
      return '';
    }
    try {
      return Uri.decodeComponent(input);
    } on FormatException {
      throw const FormatException('Input is not URL encoded.');
    }
  }
}
