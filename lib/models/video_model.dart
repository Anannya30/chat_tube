class VideoModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final String youtubeId;
  final String description;
  final String channel;

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.youtubeId,
    required this.description,
    required this.channel,
  });

  // Convert JSON to VideoModel
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      youtubeId: json['youtubeId'],
      description: json['descrption'],
      channel: json['channel'],
    );
  }

  // Convert VideoModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'youtubeId': youtubeId,
      'desciption': description,
      'channel': channel,
    };
  }
}
