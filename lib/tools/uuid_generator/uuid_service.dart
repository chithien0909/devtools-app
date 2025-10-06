import 'package:uuid/uuid.dart';

class UuidService {
  final _uuid = const Uuid();

  String generateV1() {
    return _uuid.v1();
  }

  String generateV4() {
    return _uuid.v4();
  }

  String generateV7() {
    return _uuid.v7();
  }

  List<String> generateBulk({required int count, required String version}) {
    final List<String> result = [];
    for (int i = 0; i < count; i++) {
      switch (version) {
        case 'v1':
          result.add(generateV1());
          break;
        case 'v4':
          result.add(generateV4());
          break;
        case 'v7':
          result.add(generateV7());
          break;
      }
    }
    return result;
  }
}
