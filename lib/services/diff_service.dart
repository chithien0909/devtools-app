// No external diff library required; intraline diffs are computed via LCS.

class DiffChunk {
  DiffChunk(this.type, this.text);

  final DiffType type;
  final String text;
}

class DiffSegment {
  DiffSegment(this.type, this.text);

  final DiffType type;
  final String text;
}

class DiffLine {
  DiffLine({required this.type, required this.text, required this.segments});

  final DiffType type;
  final String text;
  final List<DiffSegment> segments;
}

enum DiffType { equal, insert, delete }

class DiffService {
  const DiffService();

  List<DiffChunk> diffLines(String a, String b) {
    final aLines = a.split('\n');
    final bLines = b.split('\n');
    final table = _lcsTable(aLines, bLines);
    return _backtrack(aLines, bLines, table);
  }

  List<DiffLine> diffLinesWithIntraline(String a, String b) {
    final chunks = diffLines(a, b);
    final lines = <DiffLine>[];
    for (var i = 0; i < chunks.length; i++) {
      final current = chunks[i];
      if (current.type == DiffType.delete &&
          i + 1 < chunks.length &&
          chunks[i + 1].type == DiffType.insert) {
        final added = chunks[++i];
        lines.add(
          DiffLine(
            type: DiffType.delete,
            text: current.text,
            segments: _buildInlineSegments(
              current.text,
              added.text,
              DiffType.delete,
            ),
          ),
        );
        lines.add(
          DiffLine(
            type: DiffType.insert,
            text: added.text,
            segments: _buildInlineSegments(
              current.text,
              added.text,
              DiffType.insert,
            ),
          ),
        );
      } else {
        lines.add(
          DiffLine(
            type: current.type,
            text: current.text,
            segments: [DiffSegment(current.type, current.text)],
          ),
        );
      }
    }
    return lines;
  }

  List<List<int>> _lcsTable(List<String> a, List<String> b) {
    final rows = a.length;
    final cols = b.length;
    final dp = List.generate(rows + 1, (_) => List<int>.filled(cols + 1, 0));
    for (var i = 1; i <= rows; i++) {
      for (var j = 1; j <= cols; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }
    return dp;
  }

  List<DiffChunk> _backtrack(
    List<String> a,
    List<String> b,
    List<List<int>> dp,
  ) {
    var i = a.length;
    var j = b.length;
    final chunks = <DiffChunk>[];
    while (i > 0 && j > 0) {
      if (a[i - 1] == b[j - 1]) {
        chunks.add(DiffChunk(DiffType.equal, a[i - 1]));
        i--;
        j--;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        chunks.add(DiffChunk(DiffType.delete, a[i - 1]));
        i--;
      } else {
        chunks.add(DiffChunk(DiffType.insert, b[j - 1]));
        j--;
      }
    }
    while (i > 0) {
      chunks.add(DiffChunk(DiffType.delete, a[i - 1]));
      i--;
    }
    while (j > 0) {
      chunks.add(DiffChunk(DiffType.insert, b[j - 1]));
      j--;
    }
    return chunks.reversed.toList();
  }

  List<DiffSegment> _buildInlineSegments(
    String removed,
    String added,
    DiffType target,
  ) {
    final ops = _diffChars(removed, added);
    final segments = <DiffSegment>[];
    for (final op in ops) {
      if (target == DiffType.delete && op.type == DiffType.insert) continue;
      if (target == DiffType.insert && op.type == DiffType.delete) continue;
      if (op.text.isEmpty) continue;
      if (segments.isNotEmpty && segments.last.type == op.type) {
        segments[segments.length - 1] = DiffSegment(
          op.type,
          segments.last.text + op.text,
        );
      } else {
        segments.add(DiffSegment(op.type, op.text));
      }
    }
    return segments;
  }

  List<DiffSegment> _diffChars(String a, String b) {
    final aChars = a.split('');
    final bChars = b.split('');
    final rows = aChars.length;
    final cols = bChars.length;
    final dp = List.generate(rows + 1, (_) => List<int>.filled(cols + 1, 0));
    for (var i = 1; i <= rows; i++) {
      for (var j = 1; j <= cols; j++) {
        if (aChars[i - 1] == bChars[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] >= dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    var i = rows;
    var j = cols;
    final reversed = <DiffSegment>[];
    while (i > 0 && j > 0) {
      if (aChars[i - 1] == bChars[j - 1]) {
        reversed.add(DiffSegment(DiffType.equal, aChars[i - 1]));
        i--;
        j--;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        reversed.add(DiffSegment(DiffType.delete, aChars[i - 1]));
        i--;
      } else {
        reversed.add(DiffSegment(DiffType.insert, bChars[j - 1]));
        j--;
      }
    }
    while (i > 0) {
      reversed.add(DiffSegment(DiffType.delete, aChars[i - 1]));
      i--;
    }
    while (j > 0) {
      reversed.add(DiffSegment(DiffType.insert, bChars[j - 1]));
      j--;
    }

    final result = reversed.reversed.toList();
    // Merge adjacent same-type segments
    final merged = <DiffSegment>[];
    for (final seg in result) {
      if (merged.isNotEmpty && merged.last.type == seg.type) {
        merged[merged.length - 1] = DiffSegment(
          seg.type,
          merged.last.text + seg.text,
        );
      } else {
        merged.add(seg);
      }
    }
    return merged;
  }
}
