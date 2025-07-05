class Catatan {
  final String? id;
  final String idPengguna;
  final String judul;
  final String jenisCatatan;
  final DateTime? dibuatPada;
  final DateTime? diperbaruiPada;

  Catatan({
    this.id,
    required this.idPengguna,
    required this.judul,
    required this.jenisCatatan,
    this.dibuatPada,
    this.diperbaruiPada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_pengguna': idPengguna,
      'judul': judul,
      'jenis_catatan': jenisCatatan,
    };
  }

  factory Catatan.fromMap(Map<String, dynamic> map) {
    return Catatan(
      id: map['id'],
      idPengguna: map['id_pengguna'],
      judul: map['judul'],
      jenisCatatan: map['jenis_catatan'],
      dibuatPada: map['dibuat_pada'] != null ? DateTime.parse(map['dibuat_pada']) : null,
      diperbaruiPada: map['diperbarui_pada'] != null ? DateTime.parse(map['diperbarui_pada']) : null,
    );
  }
}

class Jadwal {
  final String? id;
  final String idCatatan;
  final DateTime tanggalJadwal;
  final String jamMulai;
  final String jamSelesai;
  final String? deskripsi;
  final DateTime? dibuatPada;
  final DateTime? diperbaruiPada;

  Jadwal({
    this.id,
    required this.idCatatan,
    required this.tanggalJadwal,
    required this.jamMulai,
    required this.jamSelesai,
    this.deskripsi,
    this.dibuatPada,
    this.diperbaruiPada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_catatan': idCatatan,
      'tanggal_jadwal': tanggalJadwal.toIso8601String().split('T')[0],
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'deskripsi': deskripsi,
    };
  }

  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'],
      idCatatan: map['id_catatan'],
      tanggalJadwal: DateTime.parse(map['tanggal_jadwal']),
      jamMulai: map['jam_mulai'],
      jamSelesai: map['jam_selesai'],
      deskripsi: map['deskripsi'],
      dibuatPada: map['dibuat_pada'] != null ? DateTime.parse(map['dibuat_pada']) : null,
      diperbaruiPada: map['diperbarui_pada'] != null ? DateTime.parse(map['diperbarui_pada']) : null,
    );
  }
}