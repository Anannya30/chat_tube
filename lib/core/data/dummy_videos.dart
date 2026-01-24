import 'package:chat_tube/models/video_model.dart';

// This is temporary. Later we'll fetch from Firebase/YouTube API
List<VideoModel> getDummyVideos() {
  return [
    VideoModel(
      id: '1',
      title: 'Never Gonna Give You Up - Official Video',
      thumbnailUrl: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
      duration: '3:33',
      youtubeId: 'dQw4w9WgXcQ',
    ),
    VideoModel(
      id: '2',
      title: 'The Office - Best Moments Compilation',
      thumbnailUrl: 'https://i.ytimg.com/vi/yxbLu_uITBQ/maxresdefault.jpg',
      duration: '45:22',
      youtubeId: 'yxbLu_uITBQ',
    ),
    VideoModel(
      id: '3',
      title: 'BBC - Planet Earth II Official Trailer',
      thumbnailUrl: 'https://i.ytimg.com/vi/eRsGyueVLvQ/maxresdefault.jpg',
      duration: '2:11',
      youtubeId: 'eRsGyueVLvQ',
    ),
    VideoModel(
      id: '4',
      title: 'TED - The power of vulnerability',
      thumbnailUrl: 'https://i.ytimg.com/vi/psN1DORYYV0/maxresdefault.jpg',
      duration: '20:49',
      youtubeId: 'psN1DORYYV0',
    ),
  ];
}
