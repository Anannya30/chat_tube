import 'package:flutter/material.dart';
import 'package:chat_tube/models/video_model.dart';
import 'package:chat_tube/core/data/dummy_videos.dart';
import 'package:chat_tube/features/home/widgets/video_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<VideoModel> videos = [];

  @override
  void initState() {
    super.initState();
    // Load videos when screen opens
    videos = getDummyVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatTube'),
        backgroundColor: const Color.fromARGB(255, 201, 28, 16),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              print('Search clicked');
            },
          ),
        ],
      ),
      body: videos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return VideoCard(video: videos[index]);
              },
            ),
    );
  }
}
