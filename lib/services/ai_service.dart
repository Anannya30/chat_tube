import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat_tube/core/config/api_config.dart';

class AIService {
  Future<String> getAIResponse({
    required String question,
    required String videoTranscript,
  }) async {
    try {
      final prompt =
          '''You are a helpful AI assistant that answers questions about videos.

Video Transcript:
$videoTranscript

Question: $question

Provide a clear, concise answer based on the transcript.''';

      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash-lite:generateContent',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': ApiConfig.geminiApiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 500},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return 'Error: ${response.body}';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Error: $e';
    }
  }

  /// EMBEDDINGS
  Future<List<double>> getEmbedding(String text) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash-lite:generateContent?key=${ApiConfig.geminiApiKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'content': {
            'parts': [
              {'text': text},
            ],
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<double>.from(data['embedding']['values']);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  String getDummyTranscript(String videoId) {
    return '''
This is a sample video transcript about machine learning and artificial intelligence.
Machine learning is a subset of AI that enables computers to learn from data.
Neural networks are inspired by the human brain and consist of layers of interconnected nodes.
Deep learning uses multiple layers to progressively extract higher-level features from raw input.
Common applications include image recognition, natural language processing, and recommendation systems.
''';
  }
}
