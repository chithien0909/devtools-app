class DiffChunk {
  DiffChunk(this.type, this.text);
  final DiffType type; // equal, insert, delete
  final String text;
}

enum DiffType { equal, insert, delete }

class DiffService {
  const DiffService();

  List<DiffChunk> diffLines(String a, String b) {
    final aLines = a.split('\n');
    final bLines = b.split('\n');
    final lcs = _lcsTable(aLines, bLines);
    return _backtrack(aLines, bLines, lcs);
  }

  List<List<int>> _lcsTable(List<String> a, List<String> b) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }
    return dp;
  }

  List<DiffChunk> _backtrack(List<String> a, List<String> b, List<List<int>> dp) {
    int i = a.length;
    int j = b.length;
    final chunks = <DiffChunk>[];
    while (i > 0 && j > 0) {
      if (a[i - 1] == b[j - 1]) {
        chunks.add(DiffChunk(DiffType.equal, a[i - 1]));
        i--; j--;
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
}
