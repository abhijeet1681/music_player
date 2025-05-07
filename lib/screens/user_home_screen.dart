import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import 'now_playing_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
        ],
      ),
      body: _songs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return ListTile(
                  leading: song.albumArt != null
                      ? Image.network(song.albumArt!, width: 50, height: 50)
                      : const Icon(Icons.music_note, size: 50),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NowPlayingScreen(song: song),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
