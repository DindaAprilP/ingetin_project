import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_models.dart';

class ScheduleService {
  final SupabaseClient _supabase;

  ScheduleService() : _supabase = Supabase.instance.client;

  Future<Jadwal?> getJadwalByCatatanId(String catatanId) async {
    final Map<String, dynamic>? response = await _supabase
        .from('jadwal')
        .select('*') 
        .eq('id_catatan', catatanId)
        .maybeSingle();
    if (response != null && response.isNotEmpty) {
      return Jadwal.fromMap(response);
    }
    return null;
  }

  Future<void> saveJadwal({
    required String catatanId,
    required DateTime tanggalJadwal, 
    required String jamMulai,
    required String jamSelesai,
    required String deskripsi,
    String? jadwalDetailId,
  }) async {
    final currentTimeUtc = DateTime.now().toUtc();
    final jadwalData = Jadwal(
      id: jadwalDetailId, 
      idCatatan: catatanId,
      tanggalJadwal: tanggalJadwal,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
      deskripsi: deskripsi,
      dibuatPada: jadwalDetailId == null ? currentTimeUtc : null, // Hanya set saat buat baru
      diperbaruiPada: currentTimeUtc,
    ).toMap();

    if (jadwalDetailId != null && jadwalDetailId.isNotEmpty) {
      await _supabase
          .from('jadwal')
          .update(jadwalData)
          .eq('id', jadwalDetailId);
    } else {
      await _supabase.from('jadwal').insert(jadwalData);
    }
  }

  Future<String> createNewSchedule({
    required String userId,
    required String judul,
    required DateTime tanggalJadwal,
    required String jamMulai,
    required String jamSelesai,
    String? deskripsi,
  }) async {
    final currentTimeUtc = DateTime.now().toUtc();
    final newCatatan = Catatan(
      idPengguna: userId,
      judul: judul,
      jenisCatatan: 'jadwal',
      dibuatPada: currentTimeUtc,
      diperbaruiPada: currentTimeUtc,
    );

    final response = await _supabase
        .from('catatan')
        .insert(newCatatan.toMap())
        .select('id')
        .single();
    final String idCatatan = response['id'] as String;
    final newJadwal = Jadwal(
      idCatatan: idCatatan,
      tanggalJadwal: tanggalJadwal,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
      deskripsi: deskripsi,
      dibuatPada: currentTimeUtc,
      diperbaruiPada: currentTimeUtc,
    );
    await _supabase.from('jadwal').insert(newJadwal.toMap());
    return idCatatan;
  }
}