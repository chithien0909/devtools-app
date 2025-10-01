class TextCaseService {
  String toUpperCase(String input) {
    return input.toUpperCase();
  }

  String toLowerCase(String input) {
    return input.toLowerCase();
  }

  String toTitleCase(String input) {
    if (input.isEmpty) {
      return '';
    }
    return input
        .split(' ')
        .map((word) {
          if (word.isEmpty) {
            return '';
          }
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
