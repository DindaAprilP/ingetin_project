import 'package:intl/intl.dart';

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
      'dibuat_pada': dibuatPada?.toIso8601String(),
      'diperbarui_pada': diperbaruiPada?.toIso8601String(),
    };
  }

  factory Catatan.fromMap(Map<String, dynamic> map) {
    return Catatan(
      id: map['id'] as String?,
      idPengguna: map['id_pengguna'] as String,
      judul: map['judul'] as String,
      jenisCatatan: map['jenis_catatan'] as String,
      dibuatPada: map['dibuat_pada'] != null ? DateTime.parse(map['dibuat_pada'] as String) : null,
      diperbaruiPada: map['diperbarui_pada'] != null ? DateTime.parse(map['diperbarui_pada'] as String) : null,
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
      'tanggal_jadwal': DateFormat('yyyy-MM-dd').format(tanggalJadwal),
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'deskripsi': deskripsi,
      'dibuat_pada': dibuatPada?.toIso8601String(),
      'diperbarui_pada': diperbaruiPada?.toIso8601String(),
    };
  }

  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'] as String?,
      idCatatan: map['id_catatan'] as String,
      tanggalJadwal: DateTime.parse(map['tanggal_jadwal'] as String),
      jamMulai: map['jam_mulai'] as String,
      jamSelesai: map['jam_selesai'] as String,
      deskripsi: map['deskripsi'] as String?,
      dibuatPada: map['dibuat_pada'] != null ? DateTime.parse(map['dibuat_pada'] as String) : null,
      diperbaruiPada: map['diperbarui_pada'] != null ? DateTime.parse(map['diperbarui_pada'] as String) : null,
    );
  }
}