import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart'; // For combining streams

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  List<DocumentSnapshot> _songs = [];
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _initAudioSession();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  Future<void> _playSong(int index) async {
    if (index < 0 || index >= _songs.length) return;
    final song = _songs[index];
    final url = song['url'];

    try {
      await _player.setUrl(url);
      await _player.play();
      setState(() {
        _currentIndex = index;
      });
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  void _pauseOrResume() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
    setState(() {});
  }

  void _stop() {
    _player.stop();
    setState(() {});
  }

  void _nextSong() {
    if (_currentIndex + 1 < _songs.length) {
      _playSong(_currentIndex + 1);
    }
  }

  void _previousSong() {
    if (_currentIndex - 1 >= 0) {
      _playSong(_currentIndex - 1);
    }
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
        _player.positionStream,
        _player.durationStream,
        (position, duration) =>
            DurationState(position: position, total: duration ?? Duration.zero),
      );

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _buildControls() {
    return Column(
      children: [
        StreamBuilder<DurationState>(
          stream: _durationStateStream,
          builder: (context, snapshot) {
            final durationState = snapshot.data;
            final position = durationState?.position ?? Duration.zero;
            final total = durationState?.total ?? Duration.zero;

            return Slider(
              min: 0,
              max: total.inMilliseconds.toDouble(),
              value: position.inMilliseconds
                  .toDouble()
                  .clamp(0.0, total.inMilliseconds.toDouble()),
              onChanged: (value) {
                _player.seek(Duration(milliseconds: value.toInt()));
              },
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(Icons.skip_previous), onPressed: _previousSong),
            IconButton(
              icon: Icon(_player.playing ? Icons.pause : Icons.play_arrow),
              onPressed: _pauseOrResume,
              iconSize: 36,
            ),
            IconButton(icon: Icon(Icons.stop), onPressed: _stop),
            IconButton(icon: Icon(Icons.skip_next), onPressed: _nextSong),
          ],
        ),
      ],
    );
  }

  Widget _buildSongTile(DocumentSnapshot songDoc, int index) {
    final title = songDoc['title'];

    return ListTile(
      leading: Icon(Icons.music_note),
      title: Text(title),
      trailing: IconButton(
        icon: Icon(Icons.play_arrow),
        onPressed: () => _playSong(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: Column(
        children: [
          if (_currentIndex != -1) _buildControls(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('songs').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                _songs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) =>
                      _buildSongTile(_songs[index], index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DurationState {
  final Duration position;
  final Duration total;

  DurationState({required this.position, required this.total});
}
