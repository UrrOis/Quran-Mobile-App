import 'package:flutter/material.dart';
import '../api/quran_juz_api.dart' as api;
import '../models/quran_juz.dart';
import '../models/quran_ayah.dart';
import '../api/quran_ayah_api.dart';
import '../models/surah_name_helper.dart';

class JuzListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Juz Al-Quran')),
      body: ListView.builder(
        itemCount: 30,
        itemBuilder: (context, i) {
          final juzNumber = i + 1;
          return ListTile(
            title: Text('Juz $juzNumber'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JuzReadPage(juzNumber: juzNumber),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class JuzReadPage extends StatefulWidget {
  final int juzNumber;
  const JuzReadPage({Key? key, required this.juzNumber}) : super(key: key);

  @override
  State<JuzReadPage> createState() => _JuzReadPageState();
}

class _JuzReadPageState extends State<JuzReadPage> {
  late Future<QuranJuz> _juzFuture;

  @override
  void initState() {
    super.initState();
    _juzFuture = api.QuranJuzApi().fetchJuz(widget.juzNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Juz ${widget.juzNumber}')),
      body: FutureBuilder<QuranJuz>(
        future: _juzFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat juz'));
          }
          final juz = snapshot.data;
          if (juz == null) return Center(child: Text('Tidak ada data'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (juz.name != null || juz.range != null)
                Card(
                  color: Colors.deepPurple[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (juz.name != null)
                          Text(
                            'Nama Juz: ${juz.name}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple[800],
                            ),
                          ),
                        if (juz.range != null)
                          Text(
                            'Range: ${juz.range}',
                            style: TextStyle(color: Colors.deepPurple[400]),
                          ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 12),
              ...juz.ayat.map(
                (ayah) => FutureBuilder<QuranAyah>(
                  future:
                      ayah.surahName == null || ayah.surahNumber == null
                          ? QuranAyahApi().fetchAyahByIndex(ayah.number)
                          : Future.value(ayah),
                  builder: (context, snapshot) {
                    final ayahData = snapshot.data ?? ayah;
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'QS. ${ayahData.surahNumber ?? ''} (${SurahNameHelper.getSurahNameByNumber(ayahData.surahNumber) ?? ayahData.surahName ?? ''}) : ${ayahData.numberInSurah ?? ayahData.number}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple[100]!,
                                    Colors.deepPurple[50]!,
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              child: Text(
                                ayahData.arabic,
                                textAlign: TextAlign.right,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple[900],
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              ayahData.latin,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              ayahData.translation,
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
