import 'dart:convert';

class JwtService {
  String decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return 'Invalid JWT: The token must have 3 parts.';
      }

      final header = _decodePart(parts[0]);
      final payload = _decodePart(parts[1]);

      final headerJson = jsonDecode(header);
      final payloadJson = jsonDecode(payload);

      const encoder = JsonEncoder.withIndent('  ');
      final formattedHeader = encoder.convert(headerJson);
      final formattedPayload = encoder.convert(payloadJson);

      return 'Header:\n$formattedHeader\n\nPayload:\n$formattedPayload';
    } catch (e) {
      return 'Invalid JWT: Could not decode the token.';
    }
  }

  String _decodePart(String part) {
    final normalized = base64Url.normalize(part);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return decoded;
  }
}
