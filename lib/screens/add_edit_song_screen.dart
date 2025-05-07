import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/firebase_service.dart';

class AddEditSongScreen extends StatefulWidget {
  final Song? song;

  const AddEditSongScreen({super.key, this.song});

  @override
  _AddEditSongScreenState createState() => _AddEditSongScreenState();
}

class _AddEditSongScreenState extends State<AddEditSongScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _artist;
  late String _url;
  late String? _albumArt;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _title = widget.song?.title ?? '';
    _artist = widget.song?.artist ?? '';
    _url = widget.song?.url ?? '';
    _albumArt = widget.song?.albumArt;
  }

  void _saveSong() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newSong = Song(
        id: widget.song?.id ?? '',
        title: _title,
        artist: _artist,
        url: _url,
        albumArt: _albumArt,
      );

      if (widget.song == null) {
        await _firebaseService.addSong(newSong);
      } else {
        await _firebaseService.updateSong(newSong);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song == null ? 'Add Song' : 'Edit Song'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Song Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _title = value!,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _artist,
                decoration: const InputDecoration(
                  labelText: 'Artist',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _artist = value!,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _url,
                decoration: const InputDecoration(
                  labelText: 'Audio URL',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _url = value!,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _albumArt,
                decoration: const InputDecoration(
                  labelText: 'Album Art URL (optional)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _albumArt = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveSong,
                icon: const Icon(Icons.save),
                label: const Text('Save Song'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
