// Model data untuk pengguna
class User {
  final int? id;
  final String name;
  final String email;
  final String? pesan;
  final String? kesan;
  final String? photo; // path or base64 string

  User({
    this.id,
    required this.name,
    required this.email,
    this.pesan,
    this.kesan,
    this.photo,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      pesan: map['pesan'],
      kesan: map['kesan'],
      photo: map['photo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'pesan': pesan,
      'kesan': kesan,
      'photo': photo,
    };
  }
}
