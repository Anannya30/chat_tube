import 'package:flutter/material.dart';
import 'package:chat_tube/models/video_model.dart';
import 'package:chat_tube/services/youtube_search_service.dart';
import 'package:chat_tube/features/home/widgets/video_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();

  List<VideoModel> _videos = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  Future<void> _searchVideos() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a search term'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
      _videos = [];
    });

    try {
      final videos = await _searchService.searchVideos(query);

      setState(() {
        _videos = videos;
        _isLoading = false;
      });

      if (videos.isEmpty) {
        setState(() {
          _errorMessage = 'No videos found for "$query"';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to search videos. Please try again.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _videos = [];
      _hasSearched = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB71C1C),
        elevation: 0,
        title: Text(
          'ChatTube',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            color: Color(0xFFB71C1C),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search videos...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[700]),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _searchVideos(),
                    onChanged: (value) {
                      setState(() {}); // Rebuild to show/hide clear button
                    },
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.search, color: Color(0xFFB71C1C)),
                    onPressed: _searchVideos,
                  ),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Loading state
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFB71C1C)),
            SizedBox(height: 16),
            Text(
              'Searching videos...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _searchVideos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB71C1C),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Results state
    if (_hasSearched && _videos.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '${_videos.length} videos found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                return VideoCard(video: _videos[index]);
              },
            ),
          ),
        ],
      );
    }

    // Initial empty state (no search yet)
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 100,
              color: Color(0xFFB71C1C).withOpacity(0.3),
            ),
            SizedBox(height: 24),
            Text(
              'Discover Educational Videos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Search for any topic and get AI-powered insights',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('Machine Learning'),
                _buildSuggestionChip('Physics'),
                _buildSuggestionChip('Programming'),
                _buildSuggestionChip('Mathematics'),
                _buildSuggestionChip('Biology'),
                _buildSuggestionChip('History'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
        _searchVideos();
      },
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(color: Colors.grey[800]),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
