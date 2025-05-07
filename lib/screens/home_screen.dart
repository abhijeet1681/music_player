import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import 'add_edit_song_screen.dart';
import 'now_playing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        title: Text('Music Player'),
      ),
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return ListTile(
            title: Text(song.title),
            subtitle: Text(song.artist),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NowPlayingScreen(song: song),
                  ));
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditSongScreen(song: song),
                          )).then((_) => _fetchSongs());
                    }),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteSong(song.id);
                    }),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditSongScreen(),
              )).then((_) => _fetchSongs());
        },
      ),
    );
  }
}
