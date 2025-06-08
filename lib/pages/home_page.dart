// Halaman utama aplikasi
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/auth_api.dart';
import 'profile_page.dart';
import 'prayer_time_page.dart';
import 'location_page.dart';
import 'currency_converter_page.dart';
import 'settings_page.dart';
import 'quran_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../models/hadith.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Home tab
  Map<String, dynamic>? _doa;
  bool _loadingDoa = true;
  String? _userName;

  HadithArbain? _hadithArbain;
  HadithBulughulMaram? _hadithBM;
  HadithPerawi? _hadithPerawi;
  bool _loadingHadith = true;

  HijriCalendar? _hijriCalendar;
  bool _loadingHijri = true;

  @override
  void initState() {
    super.initState();
    _fetchHijriCalendar();
    _fetchDoa();
    _fetchHadiths();
    _loadUserName();
  }

  void _fetchHijriCalendar() async {
    setState(() => _loadingHijri = true);
    try {
      final data = await ApiService().fetchHijriCalendar();
      setState(() {
        _hijriCalendar = data;
        _loadingHijri = false;
      });
    } catch (e) {
      setState(() {
        _hijriCalendar = null;
        _loadingHijri = false;
      });
    }
  }

  void _fetchDoa() async {
    setState(() => _loadingDoa = true);
    try {
      final doa = await ApiService().fetchRandomDoa();
      setState(() {
        _doa = doa['data'];
        _loadingDoa = false;
      });
    } catch (e) {
      setState(() {
        _doa = null;
        _loadingDoa = false;
      });
    }
  }

  void _fetchHadiths() async {
    setState(() => _loadingHadith = true);
    try {
      final arbain = await ApiService().fetchHadithArbain();
      final bm = await ApiService().fetchHadithBulughulMaram();
      final perawi = await ApiService().fetchHadithPerawi();
      setState(() {
        _hadithArbain = arbain;
        _hadithBM = bm;
        _hadithPerawi = perawi;
        _loadingHadith = false;
      });
    } catch (e) {
      setState(() {
        _hadithArbain = null;
        _hadithBM = null;
        _hadithPerawi = null;
        _loadingHadith = false;
      });
    }
  }

  void _loadUserName() async {
    final userMap = await AuthApi().getUserData();
    setState(() {
      _userName = userMap != null ? userMap['name'] as String : null;
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) return;
    Widget page;
    switch (index) {
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
        page = HomePage();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder:
                  (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.2, 0),
                        end: Offset(0, 0),
                      ).animate(animation),
                      child: child,
                    ),
                  ),
              child: CircleAvatar(
                key: ValueKey(_userName),
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF7F53AC)),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder:
                    (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.2),
                          end: Offset(0, 0),
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                child: Column(
                  key: ValueKey(_userName),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      _userName != null ? _userName! : '-',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child:
                  _loadingHijri
                      ? Center(child: CircularProgressIndicator())
                      : _hijriCalendar != null
                      ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.12),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _hijriCalendar!.day,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _hijriCalendar!.hijri,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    _hijriCalendar!.masehi,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      : Container(),
            ),
            if (_loadingDoa)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_doa != null)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.18),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _doa!['judul'] ?? '-',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _doa!['arab'] ?? '-',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily:
                                'Amiri', // gunakan font arab jika tersedia
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          _doa!['indo'] ?? '-',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _doa!['source'] != null
                                  ? 'Sumber: ${_doa!['source']}'
                                  : '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _fetchDoa,
                              icon: Icon(
                                Icons.refresh,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Doa Lain',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_loadingHadith)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (_hadithArbain != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.08),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu_book, color: Color(0xFF7F53AC)),
                              SizedBox(width: 8),
                              Text(
                                'Hadits Arbain',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7F53AC),
                                ),
                              ),
                              Spacer(),
                              Text(
                                '#${_hadithArbain!.no}',
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                              SizedBox(width: 8),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFF7F53AC),
                                  backgroundColor: Color(
                                    0xFF7F53AC,
                                  ).withOpacity(0.08),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  _fetchHadiths();
                                },
                                icon: Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: Color(0xFF7F53AC),
                                ),
                                label: Text('Hadits Lain'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            _hadithArbain!.judul,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _hadithArbain!.arab,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontFamily: 'Amiri', fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _hadithArbain!.indo,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_hadithBM != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.08),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu_book, color: Color(0xFF7F53AC)),
                              SizedBox(width: 8),
                              Text(
                                'Bulughul Maram',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7F53AC),
                                ),
                              ),
                              Spacer(),
                              Text(
                                '#${_hadithBM!.no}',
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                              SizedBox(width: 8),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFF7F53AC),
                                  backgroundColor: Color(
                                    0xFF7F53AC,
                                  ).withOpacity(0.08),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  _fetchHadiths();
                                },
                                icon: Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: Color(0xFF7F53AC),
                                ),
                                label: Text('Hadits Lain'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            _hadithBM!.ar,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontFamily: 'Amiri', fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _hadithBM!.id,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_hadithPerawi != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.08),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.menu_book, color: Color(0xFF7F53AC)),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Hadits 9 Perawi${_hadithPerawi!.perawi.isNotEmpty ? _hadithPerawi!.perawi : ''}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7F53AC),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '#${_hadithPerawi!.number}',
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                              SizedBox(width: 8),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFF7F53AC),
                                  backgroundColor: Color(
                                    0xFF7F53AC,
                                  ).withOpacity(0.08),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  _fetchHadiths();
                                },
                                icon: Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: Color(0xFF7F53AC),
                                ),
                                label: Text('Hadits Lain'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            _hadithPerawi!.arab,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontFamily: 'Amiri', fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _hadithPerawi!.id,
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
