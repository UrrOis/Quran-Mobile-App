// Model data untuk pengguna
class User {
  final int? id;
  final String name;
  final String email;
  final String? pesan;
  final String? kesan;

  User({
    this.id,
    required this.name,
    required this.email,
    this.pesan,
    this.kesan,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      pesan: map['pesan'],
      kesan: map['kesan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'pesan': pesan,
      'kesan': kesan,
    };
  }
}
