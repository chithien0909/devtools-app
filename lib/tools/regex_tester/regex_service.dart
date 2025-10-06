class RegexService {
  RegexMatchResult testRegex(String pattern, String testString, {
    bool caseSensitive = true,
    bool multiLine = false,
    bool dotAll = false,
  }) {
    try {
      final regex = RegExp(
        pattern,
        caseSensitive: caseSensitive,
        multiLine: multiLine,
        dotAll: dotAll,
      );

      final matches = regex.allMatches(testString).toList();
      
      final List<MatchDetail> matchDetails = [];
      for (var i = 0; i < matches.length; i++) {
        final match = matches[i];
        final groups = <String>[];
        
        for (var j = 0; j <= match.groupCount; j++) {
          groups.add(match.group(j) ?? '');
        }
        
        matchDetails.add(MatchDetail(
          index: i,
          start: match.start,
          end: match.end,
          matched: match.group(0) ?? '',
          groups: groups,
        ));
      }

      return RegexMatchResult(
        isValid: true,
        matches: matchDetails,
        matchCount: matches.length,
      );
    } catch (e) {
      return RegexMatchResult(
        isValid: false,
        error: e.toString(),
        matches: [],
        matchCount: 0,
      );
    }
  }

  String replaceMatches(String pattern, String testString, String replacement, {
    bool caseSensitive = true,
    bool multiLine = false,
    bool dotAll = false,
    bool replaceAll = true,
  }) {
    try {
      final regex = RegExp(
        pattern,
        caseSensitive: caseSensitive,
        multiLine: multiLine,
        dotAll: dotAll,
      );

      return replaceAll
          ? testString.replaceAll(regex, replacement)
          : testString.replaceFirst(regex, replacement);
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String escapePattern(String input) {
    return RegExp.escape(input);
  }
}

class RegexMatchResult {
  final bool isValid;
  final String? error;
  final List<MatchDetail> matches;
  final int matchCount;

  RegexMatchResult({
    required this.isValid,
    this.error,
    required this.matches,
    required this.matchCount,
  });
}

class MatchDetail {
  final int index;
  final int start;
  final int end;
  final String matched;
  final List<String> groups;

  MatchDetail({
    required this.index,
    required this.start,
    required this.end,
    required this.matched,
    required this.groups,
  });
}
