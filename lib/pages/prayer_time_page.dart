// Halaman untuk melihat waktu sholat berdasarkan lokasi pengguna
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/prayer_api_service.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'location_page.dart';
import 'currency_converter_page.dart';
import 'settings_page.dart';
import 'quran_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/city_search_widget.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/prayer_schedule_widget.dart';
import '../api/models/city.dart';
import '../api/models/prayer_schedule.dart';
import '../utils/database_helper.dart';
import '../utils/notification_helper.dart';

class PrayerTimePage extends StatefulWidget {
  @override
  State<PrayerTimePage> createState() => _PrayerTimePageState();
}

class _PrayerTimePageState extends State<PrayerTimePage> {
  City? _selectedCity;
  DateTime _selectedDate = DateTime.now();
  PrayerSchedule? _prayerSchedule;
  bool _loading = false;
  String? _error;
  int _selectedIndex = 2; // PrayerTime tab
  final int userId = 1; // Ganti dengan user login sebenarnya

  // Tambahkan timer untuk realtime clock
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startRealtimeClock();
  }

  void _startRealtimeClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _onCitySelected(City city) {
    setState(() {
      _selectedCity = city;
    });
    _fetchPrayerSchedule();
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchPrayerSchedule();
  }

  Future<void> _fetchPrayerSchedule() async {
    if (_selectedCity == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final dateStr =
        "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    try {
      final schedule = await PrayerApiService.getPrayerSchedule(
        _selectedCity!.id,
        dateStr,
      );
      setState(() {
        _prayerSchedule = schedule;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal mengambil jadwal sholat';
        _loading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) return;
    Widget page;
    switch (index) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = ProfilePage();
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
        page = PrayerTimePage();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Helper untuk konversi waktu ke zona lain
  String _convertTime(String time, int offsetHours) {
    try {
      final now = DateTime.now();
      final parts = time.split(":");
      if (parts.length != 2) return time;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(Duration(hours: offsetHours));
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return time;
    }
  }

  /// Widget untuk menampilkan waktu sholat dengan konversi zona waktu
  Widget _buildPrayerTimeRow(String label, String? time) {
    if (time == null || time.isEmpty) return SizedBox();
    // Jeddah UTC+3, WIB UTC+7, WITA UTC+8, WIT UTC+9
    final jeddah = _convertTime(time, -4); // WIB (UTC+7) ke Jeddah (UTC+3)
    final wib = time;
    final wita = _convertTime(time, 1); // WIB ke WITA
    final wit = _convertTime(time, 2); // WIB ke WIT
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Jeddah: $jeddah',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    'WIB: $wib',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    'WITA: $wita',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    'WIT: $wit',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jeddah = _now.toUtc().add(const Duration(hours: 3));
    final wib = _now.toUtc().add(const Duration(hours: 7));
    final wita = _now.toUtc().add(const Duration(hours: 8));
    final wit = _now.toUtc().add(const Duration(hours: 9));
    String fmt(DateTime dt) => DateFormat('HH:mm:ss').format(dt);

    return Scaffold(
      appBar: AppBar(title: Text('Jadwal Sholat')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (_selectedCity != null)
            Card(
              color: Colors.deepPurple[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jadwal sholat untuk: ${_selectedCity!.lokasi}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4527A0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Card(
            color: Colors.deepPurple[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waktu Saat Ini',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Jeddah (UTC+3): ${fmt(jeddah)}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'WIB (UTC+7): ${fmt(wib)}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'WITA (UTC+8): ${fmt(wita)}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'WIT (UTC+9): ${fmt(wit)}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CitySearchWidget(onCitySelected: _onCitySelected),
          SizedBox(height: 16),
          DatePickerWidget(
            selectedDate: _selectedDate,
            onDateChanged: _onDateChanged,
          ),
          SizedBox(height: 16),
          if (_loading) Center(child: CircularProgressIndicator()),
          if (_error != null)
            Text(_error!, style: TextStyle(color: Colors.red)),
          PrayerScheduleWidget(schedule: _prayerSchedule),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                _prayerSchedule == null
                    ? null
                    : () async {
                      final times = {
                        'subuh': _prayerSchedule?.subuh,
                        'dzuhur': _prayerSchedule?.dzuhur,
                        'ashar': _prayerSchedule?.ashar,
                        'maghrib': _prayerSchedule?.maghrib,
                        'isya': _prayerSchedule?.isya,
                      };
                      for (final entry in times.entries) {
                        if (entry.value != null) {
                          await DatabaseHelper.instance.upsertPrayerTime(
                            userId,
                            entry.key,
                            entry.value!,
                          );
                        }
                      }
                      await NotificationHelper().scheduleAllPrayerNotifications(
                        userId,
                      );
                      final allTimes = await DatabaseHelper.instance
                          .getAllPrayerTimes(userId);
                      print('Jadwal sholat di database: $allTimes');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Jadwal sholat berhasil disimpan dan notifikasi dijadwalkan!',
                          ),
                        ),
                      );
                    },
            child: Text('Simpan Jadwal Sholat Hari Ini'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => _CustomScheduleDialog(),
              );
              if (result != null &&
                  result['name'] != null &&
                  result['time'] != null) {
                await DatabaseHelper.instance.upsertPrayerTime(
                  userId,
                  result['name'],
                  result['time'],
                );
                await NotificationHelper().schedulePrayerNotification(
                  result['name'],
                  result['dateTime'],
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Jadwal custom berhasil disimpan dan notifikasi dijadwalkan!',
                    ),
                  ),
                );
                setState(() {});
              }
            },
            child: Text('Buat Jadwal Custom'),
          ),
          SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelper.instance.getCustomSchedules(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              final customSchedules = snapshot.data!;
              if (customSchedules.isEmpty)
                return Text('Belum ada jadwal custom');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal Custom:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...customSchedules.map(
                    (schedule) => Card(
                      child: ListTile(
                        title: Text(schedule['name'] ?? ''),
                        subtitle: Text(schedule['time'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                final result =
                                    await showDialog<Map<String, dynamic>>(
                                      context: context,
                                      builder:
                                          (context) => _CustomScheduleDialog(
                                            initialName: schedule['name'],
                                            initialTime: schedule['time'],
                                          ),
                                    );
                                if (result != null &&
                                    result['name'] != null &&
                                    result['time'] != null) {
                                  await DatabaseHelper.instance
                                      .updateCustomSchedule(
                                        schedule['id'],
                                        userId,
                                        result['name'],
                                        result['time'],
                                      );
                                  await NotificationHelper()
                                      .schedulePrayerNotification(
                                        result['name'],
                                        result['dateTime'],
                                      );
                                  setState(() {});
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await DatabaseHelper.instance
                                    .deleteCustomSchedule(schedule['id']);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          FutureBuilder<Map<String, String>>(
            future: DatabaseHelper.instance.getAllPrayerTimes(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              final prayerTimes = snapshot.data!;
              // Filter hanya jadwal utama
              final mainNames = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];
              final mainSchedules = Map.fromEntries(
                prayerTimes.entries.where((e) => mainNames.contains(e.key)),
              );
              if (mainSchedules.isEmpty)
                return Text('Belum ada jadwal sholat utama yang tersimpan');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal Sholat Tersimpan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...mainSchedules.entries.map(
                    (e) => Text(
                      '${e.key[0].toUpperCase()}${e.key.substring(1)}: ${e.value}',
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              );
            },
          ),
          if (_prayerSchedule != null) ...[
            _buildPrayerTimeRow('Imsak', _prayerSchedule?.imsak),
            _buildPrayerTimeRow('Subuh', _prayerSchedule?.subuh),
            _buildPrayerTimeRow('Terbit', _prayerSchedule?.terbit),
            _buildPrayerTimeRow('Dhuha', _prayerSchedule?.dhuha),
            _buildPrayerTimeRow('Dzuhur', _prayerSchedule?.dzuhur),
            _buildPrayerTimeRow('Ashar', _prayerSchedule?.ashar),
            _buildPrayerTimeRow('Maghrib', _prayerSchedule?.maghrib),
            _buildPrayerTimeRow('Isya', _prayerSchedule?.isya),
            const SizedBox(height: 16),
          ],
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _CustomScheduleDialog extends StatefulWidget {
  final String? initialName;
  final String? initialTime;
  _CustomScheduleDialog({this.initialName, this.initialTime});
  @override
  State<_CustomScheduleDialog> createState() => _CustomScheduleDialogState();
}

class _CustomScheduleDialogState extends State<_CustomScheduleDialog> {
  late TextEditingController _nameController;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    if (widget.initialTime != null) {
      final parts = widget.initialTime!.split(":");
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialName == null
            ? 'Buat Jadwal Custom'
            : 'Edit Jadwal Custom',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nama Jadwal'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedTime == null
                    ? 'Pilih Waktu'
                    : _selectedTime!.format(context),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedTime = picked;
                    });
                  }
                },
                child: Text('Pilih'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _selectedTime != null) {
              final now = DateTime.now();
              final dateTime = DateTime(
                now.year,
                now.month,
                now.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );
              Navigator.of(context).pop({
                'name': _nameController.text,
                'time': _selectedTime!.format(context),
                'dateTime': dateTime,
              });
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
