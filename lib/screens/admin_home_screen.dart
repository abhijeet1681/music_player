import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'add_edit_song_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - Manage Songs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().signOut();
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

          if (songs.isEmpty) {
            return const Center(child: Text('No songs available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: song.albumArt != null
                        ? Image.network(song.albumArt!,
                            width: 60, height: 60, fit: BoxFit.cover)
                        : const Icon(Icons.music_note, size: 40),
                  ),
                  title: Text(
                    song.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(song.artist),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditSongScreen(song: song),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _firebaseService.deleteSong(song.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditSongScreen(),
            ),
          );
        },
        label: const Text('Add Song'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
