import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import 'add_edit_song_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Song> _songs = [];

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    final songs = await _firebaseService.getSongs();
    setState(() {
      _songs = songs;
    });
  }

  void _deleteSong(String id) async {
    await _firebaseService.deleteSong(id);
    _fetchSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - Manage Songs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implement logout functionality
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _songs.isEmpty
          ? const Center(child: Text('No songs available'))
          : ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return ListTile(
                  leading: song.albumArt != null
                      ? Image.network(song.albumArt!, width: 50, height: 50)
                      : const Icon(Icons.music_note),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditSongScreen(song: song),
                            ),
                          ).then((_) => _fetchSongs());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteSong(song.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditSongScreen(),
            ),
          ).then((_) => _fetchSongs());
        },
      ),
    );
  }
}
