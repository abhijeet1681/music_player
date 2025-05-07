class Song {
  final String id;
  final String title;
  final String artist;
  final String url;
  final String? albumArt; // Added album art URL

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    this.albumArt,
  });

  factory Song.fromMap(Map<String, dynamic> data, String docId) {
    return Song(
      id: docId,
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      url: data['url'] ?? '',
      albumArt: data['albumArt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'url': url,
      'albumArt': albumArt,
    };
  }
}
