import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class SearchService {
  static const String _backendUrl = 'http://10.0.2.2:3000';

  Future<List<VideoModel>> searchVideos(String query) async {
    try {
      print(' Searching for: $query');

      final response = await http
          .get(
            Uri.parse(
              '$_backendUrl/youtube/search?text=${Uri.encodeComponent(query)}',
            ),
          )
          .timeout(Duration(seconds: 60));

      print('Response status : ${response.statusCode}');

      if (response.statusCode != 200) {
        print('search failed ; ${response.body}');
        throw Exception('Search failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final videos = (data['videos'] as List)
          .map(
            (video) => VideoModel(
              id: video['videoId'],
              title: video['title'],
              description: video['description'],
              channel: video['channel'],
              thumbnailUrl: video['thumbnail'],
              duration: _parseDuration(video['duration']),
              youtubeId: video['youtubeId'],
            ),
          )
          .toList();

      print('found ${videos.length} videos');
      return videos;
    } catch (e) {
      print('search error: $e');
      rethrow;
    }
  }

  String _parseDuration(String isoDuration) {
    final regrex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regrex.firstMatch(isoDuration);

    if (match == null) return '0:00';

    final hours = match.group(1);
    final minutes = match.group(2) ?? '0';
    final seconds = match.group(3) ?? '0';

    if (hours != null) {
      return '$hours:${minutes.padLeft(2, '0')}:${seconds.padLeft(2, '0')}';
    }

    return '${minutes}:${seconds.padLeft(2, '0')}';
  }
}
