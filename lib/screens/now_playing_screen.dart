import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class NowPlayingScreen extends StatefulWidget {
  final Song song;

  const NowPlayingScreen({super.key, required this.song});

  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();

    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing;
        _isBuffering = state.processingState == ProcessingState.buffering;
      });
    });
  }

  Future<void> _initAudio() async {
    try {
      await _player.setUrl(widget.song.url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load audio')),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: widget.song.albumArt != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.song.albumArt!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.music_note, size: 100),
                    ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.song.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.song.artist,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: _player.durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          min: 0,
                          max: duration.inMilliseconds.toDouble(),
                          value: position.inMilliseconds
                              .clamp(0, duration.inMilliseconds)
                              .toDouble(),
                          onChanged: (value) {
                            _player.seek(Duration(milliseconds: value.toInt()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position)),
                              Text(_formatDuration(duration)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 36),
                  onPressed: () {
                    // implement skip to previous
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    iconSize: 40,
                    icon: _isBuffering
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      _isPlaying ? _player.pause() : _player.play();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 36),
                  onPressed: () {
                    // implement skip to next
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
