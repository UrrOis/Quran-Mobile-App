class HadithArbain {
  final String arab;
  final String indo;
  final String judul;
  final String no;

  HadithArbain({
    required this.arab,
    required this.indo,
    required this.judul,
    required this.no,
  });

  factory HadithArbain.fromJson(Map<String, dynamic> json) {
    return HadithArbain(
      arab: json['arab'] ?? '',
      indo: json['indo'] ?? '',
      judul: json['judul'] ?? '',
      no: json['no']?.toString() ?? '',
    );
  }
}

class HadithBulughulMaram {
  final String ar;
  final String id;
  final String no;

  HadithBulughulMaram({required this.ar, required this.id, required this.no});

  factory HadithBulughulMaram.fromJson(Map<String, dynamic> json) {
    return HadithBulughulMaram(
      ar: json['ar'] ?? '',
      id: json['id'] ?? '',
      no: json['no']?.toString() ?? '',
    );
  }
}

class HadithPerawi {
  final String arab;
  final String id;
  final int number;
  final String perawi;

  HadithPerawi({
    required this.arab,
    required this.id,
    required this.number,
    required this.perawi,
  });

  factory HadithPerawi.fromJson(Map<String, dynamic> json) {
    return HadithPerawi(
      arab: json['arab'] ?? '',
      id: json['id'] ?? '',
      number:
          json['number'] is int
              ? json['number']
              : int.tryParse(json['number']?.toString() ?? '') ?? 0,
      perawi: json['perawi'] ?? '',
    );
  }
}

class HijriCalendar {
  final String day;
  final String hijri;
  final String masehi;

  HijriCalendar({required this.day, required this.hijri, required this.masehi});

  factory HijriCalendar.fromJson(Map<String, dynamic> json) {
    final dateList = json['date'] as List<dynamic>?;
    return HijriCalendar(
      day: dateList != null && dateList.length > 0 ? dateList[0] : '',
      hijri: dateList != null && dateList.length > 1 ? dateList[1] : '',
      masehi: dateList != null && dateList.length > 2 ? dateList[2] : '',
    );
  }
}
