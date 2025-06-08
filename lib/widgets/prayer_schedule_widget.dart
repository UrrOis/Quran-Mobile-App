import 'package:flutter/material.dart';
import '../api/models/prayer_schedule.dart';

class PrayerScheduleWidget extends StatelessWidget {
  final PrayerSchedule? schedule;
  const PrayerScheduleWidget({Key? key, required this.schedule})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (schedule == null) {
      return Text('Jadwal belum tersedia');
    }
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal: ${schedule!.tanggal}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Imsak: ${schedule!.imsak}'),
            Text('Subuh: ${schedule!.subuh}'),
            Text('Terbit: ${schedule!.terbit}'),
            Text('Dhuha: ${schedule!.dhuha}'),
            Text('Dzuhur: ${schedule!.dzuhur}'),
            Text('Ashar: ${schedule!.ashar}'),
            Text('Maghrib: ${schedule!.maghrib}'),
            Text('Isya: ${schedule!.isya}'),
          ],
        ),
      ),
    );
  }
}
