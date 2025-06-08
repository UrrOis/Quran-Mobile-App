// Halaman untuk melihat waktu sholat berdasarkan lokasi pengguna
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jadwal Sholat')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
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
