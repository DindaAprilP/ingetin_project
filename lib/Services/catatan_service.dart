import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_models.dart'; 
import '../models/isi_catatan_model.dart';
import '../models/item_tugas_model.dart';

class CatatanService {
  final SupabaseClient _supabase;

  CatatanService() : _supabase = Supabase.instance.client;

  Future<Catatan?> getCatatanById(String id) async {
    final response = await _supabase
        .from('catatan')
        .select('*')
        .eq('id', id)
        .maybeSingle();
    if (response != null && response.isNotEmpty) {
      return Catatan.fromMap(response);
    }
    return null;
  }

  Future<IsiCatatan?> getIsiCatatanByCatatanId(String catatanId) async {
    final response = await _supabase
        .from('isi_catatan')
        .select('id, isi_konten, dibuat_pada, diperbarui_pada')
        .eq('id_catatan', catatanId)
        .maybeSingle();
    if (response != null && response.isNotEmpty) {
      return IsiCatatan.fromMap(response);
    }
    return null;
  }

  Future<List<ItemTugas>> getItemTugasByCatatanId(String catatanId) async {
    final List<dynamic> response = await _supabase
        .from('item_tugas')
        .select('id, teks_tugas, sudah_selesai, urutan, dibuat_pada, diperbarui_pada')
        .eq('id_catatan', catatanId)
        .order('urutan', ascending: true);
    return response.map((json) => ItemTugas.fromMap(json)).toList();
  }

  Future<String> saveCatatan({
    String? catatanId,
    required String judul,
    required String jenisCatatan,
    required String userId,
  }) async {
    final currentTimeUtc = DateTime.now().toUtc();
    final Map<String, dynamic> data = {
      'judul': judul,
      'jenis_catatan': jenisCatatan,
      'diperbarui_pada': currentTimeUtc.toIso8601String(),
    };

    if (catatanId == null) {
      data['id_pengguna'] = userId;
      data['dibuat_pada'] = currentTimeUtc.toIso8601String();
      final response = await _supabase.from('catatan').insert(data).select('id').single();
      return response['id'] as String;
    } else {
      await _supabase.from('catatan').update(data).eq('id', catatanId);
      return catatanId;
    }
  }

  Future<void> saveIsiCatatan({
    required String catatanId,
    required String isiKonten,
    String? isiKontenDetailId,
  }) async {
    final currentTimeUtc = DateTime.now().toUtc();
    final isiCatatanData = IsiCatatan(
      id: isiKontenDetailId,
      idCatatan: catatanId,
      isiKonten: isiKonten,
      dibuatPada: isiKontenDetailId == null ? currentTimeUtc : null,
      diperbaruiPada: currentTimeUtc,
    ).toMap();

    if (isiKontenDetailId != null && isiKontenDetailId.isNotEmpty) {
      await _supabase.from('isi_catatan').update(isiCatatanData).eq('id', isiKontenDetailId);
    } else {
      await _supabase.from('isi_catatan').insert(isiCatatanData);
    }
  }

  Future<void> saveItemTugas({
    required String catatanId,
    required List<ItemTugas> items,
  }) async {
    await _supabase.from('item_tugas').delete().eq('id_catatan', catatanId);

    if (items.isNotEmpty) {
      final List<Map<String, dynamic>> itemsToInsert = items.map((item) => item.toMap()).toList();
      await _supabase.from('item_tugas').insert(itemsToInsert);
    }
  }
}