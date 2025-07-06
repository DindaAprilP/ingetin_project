import 'package:intl/intl.dart';

class Catatan {
  final String? id; // UUIDs are String in Dart
  final String idPengguna; // UUID is String in Dart
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

  // Method to convert Catatan object to a Map for Supabase insertion
  // We omit 'id', 'dibuat_pada', 'diperbarui_pada' as Supabase handles their defaults/generation
  Map<String, dynamic> toMap() {
    return {
      'id_pengguna': idPengguna,
      'judul': judul,
      'jenis_catatan': jenisCatatan,
    };
  }

  // Factory constructor to create a Catatan object from a Map received from Supabase
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
  final String? id; // UUIDs are String in Dart
  final String idCatatan; // Foreign key to Catatan UUID, so it's String
  final DateTime tanggalJadwal;
  final String jamMulai; // Time is stored as String "HH:MM:SS"
  final String jamSelesai; // Time is stored as String "HH:MM:SS"
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

  // Method to convert Jadwal object to a Map for Supabase insertion
  Map<String, dynamic> toMap() {
    return {
      'id_catatan': idCatatan,
      // Format DateTime to 'YYYY-MM-DD' string for PostgreSQL DATE type
      'tanggal_jadwal': DateFormat('yyyy-MM-dd').format(tanggalJadwal),
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'deskripsi': deskripsi,
    };
  }

  // Factory constructor to create a Jadwal object from a Map received from Supabase
  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'] as String?,
      idCatatan: map['id_catatan'] as String,
      // Parse 'YYYY-MM-DD' string back to DateTime
      tanggalJadwal: DateTime.parse(map['tanggal_jadwal'] as String),
      jamMulai: map['jam_mulai'] as String,
      jamSelesai: map['jam_selesai'] as String,
      deskripsi: map['deskripsi'] as String?,
      dibuatPada: map['dibuat_pada'] != null ? DateTime.parse(map['dibuat_pada'] as String) : null,
      diperbaruiPada: map['diperbarui_pada'] != null ? DateTime.parse(map['diperbarui_pada'] as String) : null,
    );
  }
}