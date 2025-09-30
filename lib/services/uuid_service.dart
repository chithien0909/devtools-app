import 'package:uuid/uuid.dart';

class UuidService {
  const UuidService();

  static final Uuid _uuid = Uuid();

  Future<String> generateV4(String input) async {
    return _uuid.v4();
  }

  Future<String> generateV5(String input) async {
    final seed = input.trim().isEmpty ? 'devtools.plus' : input.trim();
    return _uuid.v5(Namespace.url.value, seed);
  }
}
