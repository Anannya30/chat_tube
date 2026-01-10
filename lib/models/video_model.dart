class VideoModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final String youtubeId; // We'll need this later for actual videos

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.youtubeId,
  });

  // Convert JSON to VideoModel (you'll need this for Firebase later)
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      youtubeId: json['youtubeId'],
    );
  }

  // Convert VideoModel to JSON (for storing in Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'youtubeId': youtubeId,
    };
  }
}
