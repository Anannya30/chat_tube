import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_tube/models/chat_message.dart';
import 'package:chat_tube/models/video_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveChatMessage({
    required String videoId,
    required ChatMessage message,
  }) async {
    try {
      await _db
          .collection('videos')
          .doc(videoId)
          .collection('chats')
          .add(message.toJson());

      print('Message saved: ${message.text.substring(0, 30)}...');
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  Future<void> clearChatHistory(String videoId) async {
    try {
      print('Clearing chat history for video: $videoId');

      final batch = _db.batch();
      final chats = await _db
          .collection('videos')
          .doc(videoId)
          .collection('chats')
          .get();

      for (var doc in chats.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Chat history cleared: ${chats.docs.length} messages deleted');
    } catch (e) {
      print('Error clearing chat: $e');
    }
  }

  Future<void> saveTranscript({
    required String videoId,
    required String transcript,
  }) async {
    try {
      await _db.collection('transcripts').doc(videoId).set({
        'videoId': videoId,
        'transcript': transcript,
        'cachedAt': FieldValue.serverTimestamp(),
        'length': transcript.length,
      });

      print('Transcript cached: ${transcript.length} chars');
    } catch (e) {
      print('Error saving transcript: $e');
    }
  }

  Future<String?> getCachedTranscript(String videoId) async {
    try {
      final doc = await _db.collection('transcripts').doc(videoId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        print('Found cached transcript: ${data['length']} chars');
        return data['transcript'] as String?;
      }

      print('No cached transcript found');
      return null;
    } catch (e) {
      print('Error loading cached transcript: $e');
      return null;
    }
  }

  Future<void> addToFavorites(VideoModel video) async {
    try {
      await _db.collection('favorites').doc(video.id).set(video.toJson());
      print('Video added to favorites: ${video.title}');
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String videoId) async {
    try {
      await _db.collection('favorites').doc(videoId).delete();
      print('Video removed from favorites');
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  Future<List<VideoModel>> getFavorites() async {
    try {
      final snapshot = await _db.collection('favorites').get();

      return snapshot.docs
          .map((doc) => VideoModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  Future<bool> isFavorite(String videoId) async {
    try {
      final doc = await _db.collection('favorites').doc(videoId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Future<List<ChatMessage>> getChatHistory(String videoId) async {
    try {
      final snapshot = await _db
          .collection('videos')
          .doc(videoId)
          .collection('chats')
          .orderBy('timestamp', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }
}
