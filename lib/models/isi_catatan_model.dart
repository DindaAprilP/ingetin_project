class IsiCatatan {
  final String? id; 
  final String idCatatan;
  final String isiKonten;
  final DateTime? dibuatPada;
  final DateTime? diperbaruiPada;

  IsiCatatan({
    this.id,
    required this.idCatatan,
    required this.isiKonten,
    this.dibuatPada,
    this.diperbaruiPada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_catatan': idCatatan,
      'isi_konten': isiKonten,
      'dibuat_pada': dibuatPada?.toIso8601String(), 
      'diperbarui_pada': diperbaruiPada?.toIso8601String(), 
    };
  }

  factory IsiCatatan.fromMap(Map<String, dynamic> map) {
    return IsiCatatan(
      id: map['id'] as String?,
      idCatatan: map['id_catatan'] as String,
      isiKonten: map['isi_konten'] as String,
      dibuatPada: map['dibuat_pada'] != null ? DateTime.parse(map['dibuat_pada'] as String) : null,
      diperbaruiPada: map['diperbarui_pada'] != null ? DateTime.parse(map['diperbarui_pada'] as String) : null,
    );
  }
}