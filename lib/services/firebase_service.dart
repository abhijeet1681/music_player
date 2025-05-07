import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';

class FirebaseService {
  final CollectionReference _songsCollection =
      FirebaseFirestore.instance.collection('songs');

  // Get all songs
  Stream<List<Song>> get songsStream {
    return _songsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Song.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add a new song
  Future<void> addSong(Song song) async {
    try {
      await _songsCollection.add(song.toMap());
    } catch (e) {
      print("Error adding song: $e");
      rethrow;
    }
  }

  // Update a song
  Future<void> updateSong(Song song) async {
    try {
      await _songsCollection.doc(song.id).update(song.toMap());
    } catch (e) {
      print("Error updating song: $e");
      rethrow;
    }
  }

  // Delete a song
  Future<void> deleteSong(String id) async {
    try {
      await _songsCollection.doc(id).delete();
    } catch (e) {
      print("Error deleting song: $e");
      rethrow;
    }
  }
}
