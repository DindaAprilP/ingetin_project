class ProfilPengguna {
  final String id; // UUID from auth.users, so String
  final String namaPengguna;
  final String? urlAvatar; // TEXT in DB, so String?
  final DateTime? dibuatPada;
  final DateTime? diperbaruiPada;

  ProfilPengguna({
    required this.id,
    required this.namaPengguna,
    this.urlAvatar,
    this.dibuatPada,
    this.diperbaruiPada,
  });

  // Convert a ProfilPengguna object into a Map for Supabase insertion/update
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include ID for updates
      'nama_pengguna': namaPengguna,
      'url_avatar': urlAvatar,
      // 'dibuat_pada' and 'diperbarui_pada' are handled by DB triggers,
      // so no need to send them on insert/update unless explicitly overriding.
    };
  }

  // Create a ProfilPengguna object from a Map received from Supabase
  factory ProfilPengguna.fromMap(Map<String, dynamic> map) {
    return ProfilPengguna(
      id: map['id'] as String,
      namaPengguna: map['nama_pengguna'] as String,
      urlAvatar: map['url_avatar'] as String?,
      dibuatPada: map['dibuat_pada'] != null ? DateTime.parse(map['dibuat_pada'] as String) : null,
      diperbaruiPada: map['diperbarui_pada'] != null ? DateTime.parse(map['diperbarui_pada'] as String) : null,
    );
  }
}