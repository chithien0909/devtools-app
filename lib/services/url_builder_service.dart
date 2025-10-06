class UrlBuilderService {
  const UrlBuilderService();

  Uri parse(String input) {
    return Uri.parse(input);
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
      port: port ?? 0,
      path: path,
      queryParameters: query.isEmpty ? null : query,
      fragment: fragment,
      userInfo: userInfo ?? '',
    );
  }
}
