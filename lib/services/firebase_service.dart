import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';

class FirebaseService {
  final CollectionReference _songsCollection =
      FirebaseFirestore.instance.collection('songs');

  Future<List<Song>> getSongs() async {
    try {
      final querySnapshot = await _songsCollection.get();
      return querySnapshot.docs
          .map(
              (doc) => Song.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error getting songs: $e");
      return [];
    }
  }

  Future<void> addSong(Song song) async {
    try {
      await _songsCollection.add(song.toMap());
    } catch (e) {
      print("Error adding song: $e");
      rethrow;
    }
  }

  Future<void> updateSong(Song song) async {
    try {
      await _songsCollection.doc(song.id).update(song.toMap());
    } catch (e) {
      print("Error updating song: $e");
      rethrow;
    }
  }

  Future<void> deleteSong(String id) async {
    try {
      await _songsCollection.doc(id).delete();
    } catch (e) {
      print("Error deleting song: $e");
      rethrow;
    }
  }
}
