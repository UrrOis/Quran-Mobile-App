import 'package:flutter/material.dart';
import '../api/quran_api.dart';
import '../models/quran_surah.dart';
import '../models/surah_name_helper.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'prayer_time_page.dart';
import 'location_page.dart';
import 'currency_converter_page.dart';
import 'settings_page.dart';
import 'juz_list_page.dart';

class QuranPage extends StatefulWidget {
  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  List<QuranSurah> _surahList = [];
  bool _loading = true;
  String? _error;
  int _selectedTab = 0; // 0: Juz, 1: Surat

  @override
  void initState() {
    super.initState();
    _fetchSurahList();
  }

  Future<void> _fetchSurahList() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final surahList = await QuranApi().fetchAllSurah();
      await SurahNameHelper.init(surahList); // Inisialisasi helper nama surat
      setState(() {
        _surahList = surahList;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat daftar surat (Exception: \\${e.toString()})';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Baca Al-Quran')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedTab == 0
                            ? Colors.deepPurple[700]
                            : Colors.deepPurple[100],
                    foregroundColor:
                        _selectedTab == 0
                            ? Colors.white
                            : Colors.deepPurple[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedTab = 0;
                    });
                  },
                  child: Text(
                    'Juz',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedTab == 1
                            ? Colors.deepPurple[700]
                            : Colors.deepPurple[100],
                    foregroundColor:
                        _selectedTab == 1
                            ? Colors.white
                            : Colors.deepPurple[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedTab = 1;
                    });
                  },
                  child: Text(
                    'Surat',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child:
                _selectedTab == 0
                    ? JuzListPage()
                    : _loading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.separated(
                      padding: EdgeInsets.all(16),
                      itemCount: _surahList.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final surah = _surahList[i];
                        return Card(
                          color: Colors.deepPurple[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple[100],
                              child: Text(
                                surah.number,
                                style: TextStyle(
                                  color: Colors.deepPurple[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              surah.nameId,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[800],
                              ),
                            ),
                            subtitle: Text(
                              'Surat ke-${surah.number} | ${surah.translationId}',
                              style: TextStyle(color: Colors.deepPurple[400]),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.deepPurple[300],
                            ),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            SurahDetailPage(surah: surah),
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 6,
        onTap: (index) {
          if (index == 3) return;
          Widget page;
          switch (index) {
            case 0:
              page = HomePage();
              break;
            case 1:
              page = ProfilePage();
              break;
            case 2:
              page = PrayerTimePage();
              break;
            case 3:
              page = QuranPage();
              break;
            case 4:
              page = LocationPage();
              break;
            case 5:
              page = CurrencyConverterPage();
              break;
            case 6:
              page = SettingsPage();
              break;
            default:
              page = QuranPage();
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}

class SurahDetailPage extends StatefulWidget {
  final QuranSurah surah;
  const SurahDetailPage({required this.surah, Key? key}) : super(key: key);

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSurahDetail();
  }

  Future<void> _fetchSurahDetail() async {
    setState(() {
      _loading = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surah.nameId)),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Nama Latin: ${widget.surah.nameEn}'),
                  Text('Nama Arab: ${widget.surah.nameLong}'),
                  Text('Nama ID: ${widget.surah.nameId}'),
                  Text('Jumlah Ayat: ${widget.surah.numberOfVerses}'),
                  Text('Revelation: ${widget.surah.revelationId}'),
                  SizedBox(height: 16),
                  Text('Arti: ${widget.surah.translationId}'),
                  SizedBox(height: 16),
                  Text(
                    'Tafsir:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.surah.tafsir),
                  SizedBox(height: 24),
                ],
              ),
    );
  }
}
