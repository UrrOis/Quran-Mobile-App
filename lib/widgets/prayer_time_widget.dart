// Widget untuk menampilkan waktu sholat
import 'package:flutter/material.dart';
import '../models/prayer_time.dart';

class PrayerTimeWidget extends StatelessWidget {
  final PrayerTime prayerTime;
  const PrayerTimeWidget({required this.prayerTime, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fajr: \\${prayerTime.fajr}'),
            Text('Dhuhr: \\${prayerTime.dhuhr}'),
            Text('Asr: \\${prayerTime.asr}'),
            Text('Maghrib: \\${prayerTime.maghrib}'),
            Text('Isha: \\${prayerTime.isha}'),
          ],
        ),
      ),
    );
  }
}
