
import 'package:diff_match_patch/diff_match_patch.dart' as dmp;

class DiffService {
  const DiffService();

  Future<String> diff(String text1, String text2) async {
    final diffs = dmp.diff(text1, text2);
    return diffs.toString();
  }
}
