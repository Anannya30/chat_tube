import 'package:chat_tube/models/video_model.dart';

// This is temporary. Later we'll fetch from Firebase/YouTube API
List<VideoModel> getDummyVideos() {
  return [
    VideoModel(
      id: '1',
      title: 'Introduction to Machine Learning',
      thumbnailUrl: 'https://i.ytimg.com/vi/ukzFI9rgwfU/maxresdefault.jpg',
      duration: '10:30',
      youtubeId: 'ukzFI9rgwfU',
    ),
    VideoModel(
      id: '2',
      title: 'Flutter Complete Tutorial',
      thumbnailUrl: 'https://i.ytimg.com/vi/1ukSR1GRtMU/maxresdefault.jpg',
      duration: '15:45',
      youtubeId: '1ukSR1GRtMU',
    ),
    VideoModel(
      id: '3',
      title: 'Understanding Neural Networks',
      thumbnailUrl: 'https://i.ytimg.com/vi/aircAruvnKk/maxresdefault.jpg',
      duration: '20:15',
      youtubeId: 'aircAruvnKk',
    ),
    VideoModel(
      id: '4',
      title: 'Flutter & Firebase App Tutorial #1 - Introduction',
      thumbnailUrl: 'https://i.ytimg.com/vi/sfA3NWDBPZ4/maxresdefault.jpg',
      duration: '08:30',
      youtubeId: 'sfA3NWDBPZ4',
    ),
  ];
}
