import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_models.dart'; 
import '../models/item_tugas_model.dart';
import '../services/catatan_service.dart';
import '../services/schedule_service.dart'; 
import '../widgets/catatan_form_widget.dart';
import '../widgets/jadwal_form_widget.dart';
import '../widgets/todo_list_form_widget.dart';

class EditCatatanScreen extends StatefulWidget {
  final Catatan? catatan;
  const EditCatatanScreen({super.key, this.catatan});

  @override
  State<EditCatatanScreen> createState() => _EditCatatanScreenState();
}

class _EditCatatanScreenState extends State<EditCatatanScreen> {
  final _catatanService = CatatanService();
  final _scheduleService = ScheduleService(); 
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulController;
  late TextEditingController _isiKontenController;
  String? _isiKontenDetailId;

  final List<TextEditingController> _todoControllers = [];
  final List<bool> _todoChecked = [];

  late TextEditingController _deskripsiJadwalController;
  late TextEditingController _tanggalJadwalController;
  late TextEditingController _jamMulaiController;
  late TextEditingController _jamSelesaiController;
  String? _jadwalDetailId;

  late String _jenisCatatan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _judulController = TextEditingController();
    _isiKontenController = TextEditingController();
    _deskripsiJadwalController = TextEditingController();
    _tanggalJadwalController = TextEditingController();
    _jamMulaiController = TextEditingController();
    _jamSelesaiController = TextEditingController();

    if (widget.catatan != null) {
      _judulController.text = widget.catatan!.judul;
      _jenisCatatan = widget.catatan!.jenisCatatan;
      _loadInitialDetails();
    } else {
      _judulController.text = '';
      _jenisCatatan = 'catatan';
      if (_jenisCatatan == 'tugas') {
        _addEmptyTodoItems(3);
      }
    }
  }

  void _addEmptyTodoItems(int count) {
    for (int i = 0; i < count; i++) {
      _todoControllers.add(TextEditingController());
      _todoChecked.add(false);
    }
  }

  Future<void> _loadInitialDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_jenisCatatan == 'catatan') {
        final isiCatatan = await _catatanService.getIsiCatatanByCatatanId(widget.catatan!.id!);
        if (isiCatatan != null) {
          _isiKontenController.text = isiCatatan.isiKonten;
          _isiKontenDetailId = isiCatatan.id;
        } else {
          _isiKontenDetailId = null;
        }
      } else if (_jenisCatatan == 'tugas') {
        final List<ItemTugas> items = await _catatanService.getItemTugasByCatatanId(widget.catatan!.id!);
        setState(() {
          _todoControllers.clear();
          _todoChecked.clear();
          for (var item in items) {
            _todoControllers.add(TextEditingController(text: item.teksTugas));
            _todoChecked.add(item.sudahSelesai);
          }
          while (_todoControllers.length < 3) {
            _todoControllers.add(TextEditingController());
            _todoChecked.add(false);
          }
        });
      } else if (_jenisCatatan == 'jadwal') {
        final jadwal = await _scheduleService.getJadwalByCatatanId(widget.catatan!.id!);
        if (jadwal != null) {
          _jadwalDetailId = jadwal.id;
          _deskripsiJadwalController.text = jadwal.deskripsi ?? '';
          _tanggalJadwalController.text = jadwal.tanggalJadwal.toIso8601String().split('T')[0];
          _jamMulaiController.text = jadwal.jamMulai;
          _jamSelesaiController.text = jadwal.jamSelesai;
        } else {
          _jadwalDetailId = null;
        }
      }
    } catch (e) {
      print('Error loading initial details: $e');
      if (mounted) {
        Get.snackbar(
          "Gagal Memuat Data",
          "Terjadi kesalahan saat memuat detail catatan: ${e.toString()}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiKontenController.dispose();
    _deskripsiJadwalController.dispose();
    _tanggalJadwalController.dispose();
    _jamMulaiController.dispose();
    _jamSelesaiController.dispose();

    for (var controller in _todoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      String? currentCatatanId = widget.catatan?.id;
      currentCatatanId = await _catatanService.saveCatatan(
        catatanId: currentCatatanId,
        judul: _judulController.text.trim(),
        jenisCatatan: _jenisCatatan,
        userId: userId,
      );

      if (currentCatatanId == null) {
        throw Exception("Gagal mendapatkan ID catatan setelah disimpan.");
      }

      if (_jenisCatatan == 'catatan') {
        await _catatanService.saveIsiCatatan(
          catatanId: currentCatatanId,
          isiKonten: _isiKontenController.text.trim(),
          isiKontenDetailId: _isiKontenDetailId,
        );
      } else if (_jenisCatatan == 'tugas') {
        final List<ItemTugas> itemsToSave = [];
        for (int i = 0; i < _todoControllers.length; i++) {
          String itemText = _todoControllers[i].text.trim();
          if (itemText.isNotEmpty) {
            itemsToSave.add(ItemTugas(
              idCatatan: currentCatatanId,
              teksTugas: itemText,
              sudahSelesai: _todoChecked[i],
              urutan: i,
              dibuatPada: DateTime.now().toUtc(),
              diperbaruiPada: DateTime.now().toUtc(),
            ));
          }
        }
        await _catatanService.saveItemTugas(
          catatanId: currentCatatanId,
          items: itemsToSave,
        );
      } else if (_jenisCatatan == 'jadwal') {
        if (_tanggalJadwalController.text.trim().isEmpty ||
            _jamMulaiController.text.trim().isEmpty ||
            _jamSelesaiController.text.trim().isEmpty) {
          throw Exception('Tanggal, jam mulai, dan jam selesai wajib diisi untuk jadwal.');
        }

        DateTime parsedTanggalJadwal = DateTime.parse(_tanggalJadwalController.text.trim());
        await _scheduleService.saveJadwal(
          catatanId: currentCatatanId,
          tanggalJadwal: parsedTanggalJadwal,
          jamMulai: _jamMulaiController.text.trim(),
          jamSelesai: _jamSelesaiController.text.trim(),
          deskripsi: _deskripsiJadwalController.text.trim(),
          jadwalDetailId: _jadwalDetailId,
        );
      }

      Get.back(result: true);
      Get.snackbar(
        "Sukses",
        "${_getJenisCatatanName()} berhasil disimpan",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      print('Error saving/updating catatan: $e');
      if (mounted) {
        Get.snackbar(
          "Gagal",
          "Tidak dapat menyimpan perubahan: ${e.toString()}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getJenisCatatanName() {
    switch (_jenisCatatan) {
      case 'tugas':
        return 'To-Do List';
      case 'jadwal':
        return 'Jadwal';
      default:
        return 'Catatan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.catatan == null ? "Tambah Catatan Baru" : "Edit ${_getJenisCatatanName()}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          _isLoading
              ? Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _simpanPerubahan,
                  icon: Icon(Icons.check),
                  tooltip: 'Simpan Perubahan',
                ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Judul wajib diisi' : null,
                enabled: !_isLoading,
              ),
              SizedBox(height: 16),
              if (widget.catatan == null)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _jenisCatatan,
                      decoration: InputDecoration(
                        labelText: 'Jenis Catatan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: [
                        DropdownMenuItem(value: 'catatan', child: Text('Catatan')),
                        DropdownMenuItem(value: 'tugas', child: Text('Tugas')),
                        DropdownMenuItem(value: 'jadwal', child: Text('Jadwal')),
                      ],
                      onChanged: _isLoading ? null : (value) {
                        setState(() {
                          _jenisCatatan = value!;
                          _isiKontenController.clear();
                          _deskripsiJadwalController.clear();
                          _tanggalJadwalController.clear();
                          _jamMulaiController.clear();
                          _jamSelesaiController.clear();
                          _todoControllers.clear();
                          _todoChecked.clear();
                          if (_jenisCatatan == 'tugas') {
                            _addEmptyTodoItems(3);
                          }
                          _isiKontenDetailId = null;
                          _jadwalDetailId = null;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis catatan';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              if (_jenisCatatan == 'catatan')
                CatatanFormWidget(
                  controller: _isiKontenController,
                  isLoading: _isLoading,
                )
              else if (_jenisCatatan == 'tugas')
                TodoListFormWidget(
                  todoControllers: _todoControllers,
                  todoChecked: _todoChecked,
                  isLoading: _isLoading,
                  addEmptyTodoItems: _addEmptyTodoItems,
                  jenisCatatan: _jenisCatatan,
                  onRemoveItem: (index) {
                    setState(() {
                      if (_todoControllers.length > 1) {
                        _todoControllers[index].dispose();
                        _todoControllers.removeAt(index);
                        _todoChecked.removeAt(index);
                      } else {
                        _todoControllers[index].clear();
                        _todoChecked[index] = false;
                        Get.snackbar(
                          'Info',
                          'Minimal satu item tugas harus ada. Isi atau hapus catatan ini.',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: Duration(seconds: 2),
                        );
                      }
                    });
                  },
                )
              else if (_jenisCatatan == 'jadwal')
                  JadwalFormWidget(
                  deskripsiController: _deskripsiJadwalController,
                  tanggalController: _tanggalJadwalController,
                  jamMulaiController: _jamMulaiController,
                  jamSelesaiController: _jamSelesaiController,
                  isLoading: _isLoading,
                ),
            ],
          ),
        ),
      ),
    );
  }
}