class ProfilPengguna {
  final String id;
  final String namaPengguna;
  final String? urlAvatar;

  ProfilPengguna({
    required this.id,
    required this.namaPengguna,
    this.urlAvatar,
  });

  factory ProfilPengguna.fromMap(Map<String, dynamic> map) {
    return ProfilPengguna(
      id: map['id'],
      namaPengguna: map['nama_pengguna'],
      urlAvatar: map['url_avatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_pengguna': namaPengguna,
      'url_avatar': urlAvatar,
    };
  }
}