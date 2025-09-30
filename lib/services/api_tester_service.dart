
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTesterService {
  const ApiTesterService();

  Future<String> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return 'Status: ${response.statusCode}\n\nHeaders: ${response.headers}\n\nBody: ${response.body}';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> post(String url, String body) async {
    try {
      final response = await http.post(Uri.parse(url), body: body);
      return 'Status: ${response.statusCode}\n\nHeaders: ${response.headers}\n\nBody: ${response.body}';
    } catch (e) {
      return e.toString();
    }
  }
}
