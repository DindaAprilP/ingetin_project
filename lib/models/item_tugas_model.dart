class ItemTugas {
  final String? id; 
  final String idCatatan;
  final String teksTugas;
  final bool sudahSelesai;
  final int urutan;
  final DateTime? dibuatPada;
  final DateTime? diperbaruiPada;

  ItemTugas({
    this.id,
    required this.idCatatan,
    required this.teksTugas,
    required this.sudahSelesai,
    required this.urutan,
    this.dibuatPada,
    this.diperbaruiPada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_catatan': idCatatan,
      'teks_tugas': teksTugas,
      'sudah_selesai': sudahSelesai,
      'urutan': urutan,
      'dibuat_pada': dibuatPada?.toIso8601String(),
      'diperbarui_pada': diperbaruiPada?.toIso8601String(),
    };
  }

  factory ItemTugas.fromMap(Map<String, dynamic> map) {
    return ItemTugas(
      id: map['id'] as String?,
      idCatatan: map['id_catatan'] as String,
      teksTugas: map['teks_tugas'] as String,
      sudahSelesai: map['sudah_selesai'] as bool,
      urutan: map['urutan'] as int,
      dibuatPada: map['dibuat_pada'] != null ? DateTime.parse(map['dibuat_pada'] as String) : null,
      diperbaruiPada: map['diperbarui_pada'] != null ? DateTime.parse(map['diperbarui_pada'] as String) : null,
    );
  }
}