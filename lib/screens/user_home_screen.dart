import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'now_playing_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';
  List<Song> _filteredSongs = [];

  void _filterSongs(List<Song> songs) {
    setState(() {
      _filteredSongs = songs
          .where((song) =>
              song.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              song.artist.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎵 Music Player',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              try {
                await AuthService().signOut();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by song or artist...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  _searchQuery = value;
                  // Trigger filtering after input
                  setState(() {}); // Will re-run the StreamBuilder
                },
              ),
            ),

            // 📃 Song List
            Expanded(
              child: StreamBuilder<List<Song>>(
                stream: _firebaseService.songsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final songs = snapshot.data ?? [];

                  // Apply filter
                  _filteredSongs = _searchQuery.isEmpty
                      ? songs
                      : songs
                          .where((song) =>
                              song.title
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()) ||
                              song.artist
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                          .toList();

                  if (_filteredSongs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matching songs found.',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: _filteredSongs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final song = _filteredSongs[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: song.albumArt != null
                                ? Image.network(
                                    song.albumArt!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child:
                                        const Icon(Icons.music_note, size: 30),
                                  ),
                          ),
                          title: Text(
                            song.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            song.artist,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NowPlayingScreen(song: song),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
