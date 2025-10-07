class UrlValidationResult {
  const UrlValidationResult({required this.isValid, this.uri, this.error});

  final bool isValid;
  final Uri? uri;
  final String? error;
}

class UrlBuilderService {
  const UrlBuilderService();

  UrlValidationResult validate(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return const UrlValidationResult(
        isValid: false,
        error: 'URL cannot be empty',
      );
    }
    try {
      final uri = Uri.parse(raw);
      if (!uri.hasScheme || uri.host.isEmpty) {
        return UrlValidationResult(
          isValid: false,
          uri: uri,
          error: 'Missing scheme or host',
        );
      }
      return UrlValidationResult(isValid: true, uri: uri);
    } catch (error) {
      return UrlValidationResult(isValid: false, error: error.toString());
    }
  }

  Uri build({
    String scheme = 'https',
    String host = '',
    int? port,
    String path = '/',
    Map<String, String> query = const {},
    String? fragment,
    String? userInfo,
  }) {
    return Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: path,
      queryParameters: query.isEmpty ? null : query,
      fragment: fragment?.isEmpty ?? true ? null : fragment,
      userInfo: userInfo?.isEmpty ?? true ? null : userInfo,
    );
  }

  Uri normalize(Uri uri) {
    final sortedQuery = Map.fromEntries(
      uri.queryParameters.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );
    final normalized = uri.replace(
      scheme: uri.scheme.toLowerCase(),
      host: uri.host.toLowerCase(),
      queryParameters: sortedQuery.isEmpty ? null : sortedQuery,
      port: _isDefaultPort(uri)
          ? null
          : uri.hasPort
          ? uri.port
          : null,
    );
    return normalized;
  }

  String toClipboardPayload(Uri uri) => normalize(uri).toString();

  String toShareMessage(Uri uri, {String? label}) {
    final normalized = normalize(uri);
    if (label == null || label.isEmpty) {
      return normalized.toString();
    }
    return '$label\n${normalized.toString()}';
  }

  bool _isDefaultPort(Uri uri) {
    return (uri.scheme == 'http' && uri.port == 80) ||
        (uri.scheme == 'https' && uri.port == 443);
  }
}
