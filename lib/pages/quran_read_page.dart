// This file is deprecated and no longer used after refactor to juz/surat only UI. Safe to delete.

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quran_surah.dart';
import '../models/quran_ayah.dart';
import '../api/quran_ayah_api.dart';

class QuranReadPage extends StatefulWidget {
  final QuranSurah surah;
  const QuranReadPage({Key? key, required this.surah}) : super(key: key);

  @override
  State<QuranReadPage> createState() => _QuranReadPageState();
}

class _QuranReadPageState extends State<QuranReadPage> {
  late Future<List<QuranAyah>> _ayatFuture;
  AudioPlayer? _audioPlayer;
  int? _playingAyah;

  @override
  void initState() {
    super.initState();
    _ayatFuture = QuranAyahApi().fetchAyatList(
      int.tryParse(widget.surah.number.toString()) ?? 0,
    );
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _playAyahAudio(QuranAyah ayah) async {
    if (ayah.audioUrl.isNotEmpty) {
      setState(() {
        _playingAyah = ayah.number;
      });
      await _audioPlayer?.play(UrlSource(ayah.audioUrl));
      _audioPlayer?.onPlayerComplete.listen((event) {
        setState(() {
          _playingAyah = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Baca ${widget.surah.nameId}')),
      body: FutureBuilder<List<QuranAyah>>(
        future: _ayatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat ayat'));
          }
          final ayatList = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ayatList.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (context, i) {
              final ayah = ayatList[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(child: Text(ayah.number.toString())),
                          IconButton(
                            icon: Icon(
                              _playingAyah == ayah.number
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            onPressed:
                                ayah.audioUrl.isEmpty
                                    ? null
                                    : () => _playAyahAudio(ayah),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        ayah.arabic,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        ayah.latin,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 8),
                      Text(
                        ayah.translation,
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
