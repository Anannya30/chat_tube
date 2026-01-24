import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat_tube/services/firebase_services.dart';

class TranscriptService {
  final FirestoreService _firestore = FirestoreService();
  static const String _backendUrl =
      'http://10.0.2.2:3000'; // Android emulator localhost

  /// Main method (replaces youtube_explode_dart)
  Future<String?> getAndCacheTranscript(String videoId) async {
    print('🔍 Starting transcript fetch for video: $videoId');

    // 1️⃣ Check Firestore cache first
    print('📦 Checking Firestore cache...');
    try {
      final cached = await _firestore.getCachedTranscript(videoId);
      if (cached != null && cached.isNotEmpty) {
        print('✅ Using cached transcript (${cached.length} chars)');
        return cached;
      }
      print('⚠️ No cached transcript found');
    } catch (e) {
      print('❌ Cache check error: $e');
    }

    // 2️⃣ Fetch from local backend
    print('🌐 Fetching from backend: $_backendUrl/transcript?videoId=$videoId');
    try {
      final url = Uri.parse('$_backendUrl/transcript?videoId=$videoId');
      print('📤 Sending request to: $url');

      final response = await http
          .get(url)
          .timeout(
            const Duration(minutes: 3),
            onTimeout: () {
              print('⏱️ Backend request timeout after 30 seconds');
              throw TimeoutException('Backend request timeout');
            },
          );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body length: ${response.body.length}');
      print(
        '📥 Response body preview: ${response.body.substring(0, (response.body.length < 200 ? response.body.length : 200))}',
      );

      if (response.statusCode != 200) {
        print('❌ Backend error (${response.statusCode}): ${response.body}');
        return null;
      }

      if (response.body.isEmpty) {
        print('❌ Empty response from backend');
        return null;
      }

      try {
        final data = jsonDecode(response.body);
        final transcript = data['transcript'] as String?;

        if (transcript == null || transcript.isEmpty) {
          print('⏳ Transcript still processing');
          throw Exception('TRANSCRIPT_PENDING');
        }

        print('✅ Got transcript: ${transcript.length} characters');

        // 3️⃣ Save to Firestore
        print('💾 Saving transcript to Firestore...');
        await _firestore.saveTranscript(
          videoId: videoId,
          transcript: transcript,
        );

        print('✅ Transcript saved to Firestore');

        return transcript;
      } catch (parseError) {
        print('❌ JSON parse error: $parseError');
        print('❌ Response was: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Backend fetch error: $e');
      return null;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
