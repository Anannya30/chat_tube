import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../models/video_model.dart';
import '../../../models/chat_message.dart';
import '../../../services/ai_service.dart';
import '../../../services/firebase_services.dart';
import '../../../services/transcript_service.dart';

class VideoScreen extends StatefulWidget {
  final VideoModel video;

  const VideoScreen({required this.video});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late YoutubePlayerController _controller;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final AIService _aiService = AIService();
  final FirestoreService _firestoreService = FirestoreService();
  late TranscriptService _transcriptService;

  bool _isLoading = false;
  bool _isLoadingTranscript = true;
  bool _isLoadingHistory = true;
  bool _isFavorite = false;
  String? _transcript;
  String? _transcriptError;

  @override
  void initState() {
    super.initState();

    _transcriptService = TranscriptService();

    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    _loadTranscript();
    _checkFavoriteStatus();
  }

  Future<void> _loadTranscript() async {
    setState(() {
      _isLoadingTranscript = true;
      _transcriptError = null;
    });

    try {
      final transcript = await _transcriptService.getAndCacheTranscript(
        widget.video.youtubeId,
      );

      if (!mounted) return;

      // ✅ SUCCESS CASE
      if (transcript != null && transcript.trim().isNotEmpty) {
        setState(() {
          _transcript = transcript;
          _isLoadingTranscript = false;
        });
        return;
      }

      // ⏳ STILL PROCESSING → retry after delay
      print('⏳ Transcript not ready yet, retrying in 5s...');
      Future.delayed(const Duration(seconds: 5), _loadTranscript);
    } catch (e) {
      if (!mounted) return;

      // ⏳ Backend still working → retry
      if (e.toString().contains('PENDING') ||
          e.toString().contains('timeout')) {
        print('⏳ Backend still processing, retrying...');
        Future.delayed(const Duration(seconds: 5), _loadTranscript);
        return;
      }

      // ❌ REAL FAILURE
      setState(() {
        _transcriptError = 'Transcript could not be generated';
        _isLoadingTranscript = false;
      });
    }
  }

  // Check if video is in favorites
  Future<void> _checkFavoriteStatus() async {
    final isFav = await _firestoreService.isFavorite(widget.video.id);
    setState(() {
      _isFavorite = isFav;
    });
  }

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _firestoreService.removeFromFavorites(widget.video.id);
      setState(() {
        _isFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed from favorites'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      await _firestoreService.addToFavorites(widget.video);
      setState(() {
        _isFavorite = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to favorites'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Send message to AI
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    if (_transcript == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_transcriptError ?? 'Transcript is still loading...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userMessage = _messageController.text;
    _messageController.clear();

    final userChatMessage = ChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userChatMessage);
      _isLoading = true;
    });

    // Scroll to bottom
    _scrollToBottom();

    // Save user message to Firebase
    await _firestoreService.saveChatMessage(
      videoId: widget.video.id,
      message: userChatMessage,
    );

    try {
      final aiResponse = await _aiService.getAIResponse(
        question: userMessage,
        videoTranscript: _transcript!,
      );

      final aiChatMessage = ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiChatMessage);
        _isLoading = false;
      });

      // Scroll to bottom
      _scrollToBottom();

      // Save AI response to Firebase
      await _firestoreService.saveChatMessage(
        videoId: widget.video.id,
        message: aiChatMessage,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  // Clear chat
  void _clearChat() async {
    // Confirm before clearing
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat History?'),
        content: Text(
          'This will permanently delete all messages for this video.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Clear from Firebase
    await _firestoreService.clearChatHistory(widget.video.id);

    setState(() {
      _messages.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chat cleared'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Scroll to bottom of messages
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatTube'),
        backgroundColor: Color(0xFFB71C1C),
        actions: [
          // Favorite button
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.pink : Colors.white,
            ),
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: _toggleFavorite,
          ),

          // Transcript status indicator
          if (_isLoadingTranscript)
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else if (_transcript != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.check_circle, color: Colors.greenAccent),
            )
          else
            Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.error, color: Colors.orange),
            ),

          // Clear chat button
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
            onPressed: _messages.isEmpty ? null : _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
          ),

          // Video Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      widget.video.duration,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(width: 16),
                    // Transcript status
                    if (_isLoadingTranscript)
                      Text(
                        'Loading transcript...',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else if (_transcript != null)
                      Text(
                        '✓ Transcript ready',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else if (_transcriptError != null)
                      Text(
                        '⚠ ${_transcriptError!}',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      )
                    else
                      Text(
                        'Loading transcript...',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Chat Section
          Expanded(
            child: Column(
              children: [
                // Messages List
                Expanded(
                  child: _isLoadingHistory
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Loading chat history...'),
                            ],
                          ),
                        )
                      : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _isLoadingTranscript
                                    ? 'Loading transcript...'
                                    : _transcript == null
                                    ? 'This video has no captions'
                                    : 'Ask me anything about this video!',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _ChatBubble(message: _messages[index]);
                          },
                        ),
                ),

                // Loading indicator
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'AI is thinking...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Message Input
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isLoading && _transcript != null,
                          decoration: InputDecoration(
                            hintText: _isLoadingTranscript
                                ? 'Loading transcript...'
                                : _transcript == null
                                ? 'No captions available'
                                : 'Ask about the video...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: (_isLoading || _transcript == null)
                            ? Colors.grey
                            : Colors.blue,
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: (_isLoading || _transcript == null)
                              ? null
                              : _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.green[100],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
