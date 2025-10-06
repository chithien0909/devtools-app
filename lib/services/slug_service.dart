class SlugService {
  const SlugService();

  String slugify(String input, {String replacement = '-'}) {
    if (input.trim().isEmpty) return '';
    final rep = RegExp.escape(replacement);
    var slug = input.toLowerCase();
    slug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), replacement);
    slug = slug.replaceAll(RegExp('$rep{2,}'), replacement);
    slug = slug.replaceAll(RegExp('^' + rep + r'|' + rep + r'$'), '');
    return slug;
  }

  String normalizeWhitespace(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
