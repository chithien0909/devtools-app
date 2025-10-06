class UrlService {
  String encodeUrl(String input) {
    return Uri.encodeComponent(input);
  }

  String decodeUrl(String input) {
    return Uri.decodeComponent(input);
  }

  String encodeQueryParameters(String input) {
    return Uri.encodeQueryComponent(input);
  }

  String decodeQueryParameters(String input) {
    return Uri.decodeQueryComponent(input);
  }

  String encodeFull(String input) {
    return Uri.encodeFull(input);
  }

  String decodeFull(String input) {
    return Uri.decodeFull(input);
  }

  Map<String, String> parseQueryString(String queryString) {
    if (queryString.isEmpty) return {};
    
    if (queryString.startsWith('?')) {
      queryString = queryString.substring(1);
    }
    
    return Uri.splitQueryString(queryString);
  }

  String buildQueryString(Map<String, String> params) {
    if (params.isEmpty) return '';
    
    return params.entries
        .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
  }
}
