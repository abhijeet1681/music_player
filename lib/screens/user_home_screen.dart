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
      body: StreamBuilder<List<Song>>(
        stream: _firebaseService.songsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = snapshot.data!;

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
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
          );
        },
      ),
    );
  }
}
