import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  Future<Map<String, dynamic>> askQuestion(String question) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:3000/ask"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"question": question}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Backend error: ${response.body}");
    }
  }
}
