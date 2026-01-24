import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Add validation
  static bool get isConfigured => geminiApiKey.isNotEmpty;
}
