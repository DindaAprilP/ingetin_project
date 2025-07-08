import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditCatatan extends StatefulWidget {
  final Map<String, dynamic>? catatan;

  const EditCatatan({super.key, this.catatan});

  @override
  State<EditCatatan> createState() => _EditCatatanState();
}

class _EditCatatanState extends State<EditCatatan> {
  final supabase = Supabase.instance.client; 
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
      _judulController.text = widget.catatan!['judul'] ?? '';
      _jenisCatatan = widget.catatan!['jenis_catatan'] ?? 'catatan';
      _loadInitialDetails();
    } else {
      _judulController.text = '';
      _jenisCatatan = 'catatan'; 

      if (_jenisCatatan == 'tugas') {
        for (int i = 0; i < 3; i++) {
          _todoControllers.add(TextEditingController());
          _todoChecked.add(false);
        }
      }
    }
  }

  Future<void> _loadInitialDetails() async {
    setState(() {
      _isLoading = true; 
    });
    try {
      if (_jenisCatatan == 'catatan') {
        final response = await supabase
            .from('isi_catatan')
            .select('id, isi_konten')
            .eq('id_catatan', widget.catatan!['id'])
            .maybeSingle();

        if (response != null && response.isNotEmpty) {
          _isiKontenController.text = response['isi_konten'] ?? '';
          _isiKontenDetailId = response['id'].toString();
        } else {
          _isiKontenDetailId = null; 
        }
      } else if (_jenisCatatan == 'tugas') {
        final List<dynamic> response = await supabase
            .from('item_tugas')
            .select('teks_tugas, sudah_selesai')
            .eq('id_catatan', widget.catatan!['id'])
            .order('urutan', ascending: true);

        setState(() {
          _todoControllers.clear();
          _todoChecked.clear();
          for (var item in response) {
            _todoControllers.add(TextEditingController(text: item['teks_tugas']));
            _todoChecked.add(item['sudah_selesai'] ?? false);
          }
          while (_todoControllers.length < 3) {
            _todoControllers.add(TextEditingController());
            _todoChecked.add(false);
          }
        });
      } else if (_jenisCatatan == 'jadwal') {
        final Map<String, dynamic>? response = await supabase
            .from('jadwal')
            .select('id, tanggal_jadwal, jam_mulai, jam_selesai, deskripsi')
            .eq('id_catatan', widget.catatan!['id'])
            .maybeSingle();

        if (response != null && response.isNotEmpty) {
          _jadwalDetailId = response['id'].toString();
          _deskripsiJadwalController.text = response['deskripsi'] ?? '';
          if (response['tanggal_jadwal'] != null) {
            _tanggalJadwalController.text = response['tanggal_jadwal'].toString();
          }
          _jamMulaiController.text = response['jam_mulai'] ?? '';
          _jamSelesaiController.text = response['jam_selesai'] ?? '';
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

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? initialDate;
    try {
      if (controller.text.isNotEmpty) {
        initialDate = DateTime.parse(controller.text);
      }
    } catch (e) {
      initialDate = DateTime.now();
    }
    initialDate ??= DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = pickedDate.toString().split(' ')[0]; 
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? initialTime;
    try {
      if (controller.text.isNotEmpty) {
        final parts = controller.text.split(':');
        if (parts.length >= 2) {
          initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
    } catch (e) {
      initialTime = TimeOfDay.now();
    }
    initialTime ??= TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00'; // Format HH:MM:SS
      });
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
      final userId = supabase.auth.currentUser!.id;
      final currentTime = DateTime.now().toIso8601String();
      String? currentCatatanId = widget.catatan?['id']; 

      Map<String, dynamic> catatanData = {
        'judul': _judulController.text.trim(),
        'jenis_catatan': _jenisCatatan,
        'diperbarui_pada': currentTime,
      };

      if (currentCatatanId == null) {
        catatanData['id_pengguna'] = userId;
        catatanData['dibuat_pada'] = currentTime;
        final response = await supabase.from('catatan').insert(catatanData).select('id').single();
        currentCatatanId = response['id'] as String; 
      } else {
        await supabase.from('catatan').update(catatanData).eq('id', currentCatatanId);
      }

      if (currentCatatanId == Null) {
        throw Exception("Gagal mendapatkan ID catatan.");
      }

      if (_jenisCatatan == 'catatan') {
        final isiCatatanData = {
          'id_catatan': currentCatatanId,
          'isi_konten': _isiKontenController.text.trim(),
          'diperbarui_pada': currentTime,
        };
        if (_isiKontenDetailId != null && _isiKontenDetailId!.isNotEmpty) {
          await supabase.from('isi_catatan').update(isiCatatanData).eq('id', _isiKontenDetailId!);
        } else {
          await supabase.from('isi_catatan').insert(isiCatatanData);
        }
      } else if (_jenisCatatan == 'tugas') {
        await supabase
            .from('item_tugas')
            .delete()
            .eq('id_catatan', currentCatatanId);

        List<Map<String, dynamic>> itemsToInsert = [];
        for (int i = 0; i < _todoControllers.length; i++) {
          String itemText = _todoControllers[i].text.trim();
          if (itemText.isNotEmpty) {
            itemsToInsert.add({
              'id_catatan': currentCatatanId,
              'teks_tugas': itemText,
              'sudah_selesai': _todoChecked[i],
              'urutan': i, 
              'dibuat_pada': currentTime, 
              'diperbarui_pada': currentTime,
            });
          }
        }
        if (itemsToInsert.isNotEmpty) {
          await supabase.from('item_tugas').insert(itemsToInsert);
        }
      } else if (_jenisCatatan == 'jadwal') {
        if (_tanggalJadwalController.text.trim().isEmpty ||
            _jamMulaiController.text.trim().isEmpty ||
            _jamSelesaiController.text.trim().isEmpty) {
          throw Exception('Tanggal, jam mulai, dan jam selesai wajib diisi untuk jadwal.');
        }

        final jadwalData = {
          'id_catatan': currentCatatanId,
          'tanggal_jadwal': _tanggalJadwalController.text.trim(), 
          'jam_mulai': _jamMulaiController.text.trim(), 
          'jam_selesai': _jamSelesaiController.text.trim(), 
          'deskripsi': _deskripsiJadwalController.text.trim(),
          'diperbarui_pada': currentTime,
        };

        if (_jadwalDetailId != null && _jadwalDetailId!.isNotEmpty) {
          
          await supabase
              .from('jadwal')
              .update(jadwalData)
              .eq('id', _jadwalDetailId!); 
        } else {
          await supabase.from('jadwal').insert(jadwalData);
        }
      }

      Get.back(result: true); 
      Get.snackbar(
        "Sukses",
        "${_getJenisCatatanName()} berhasil disimpan", 
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
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
          duration: const Duration(seconds: 3),
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

  Widget _buildCatatanForm() {
    return Expanded(
      child: TextFormField(
        controller: _isiKontenController,
        decoration: const InputDecoration(
          labelText: 'Isi Catatan',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        maxLines: null, 
        expands: true, 
        textAlignVertical: TextAlignVertical.top,
        enabled: !_isLoading, 
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Isi catatan tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTodoListForm() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Item Tugas:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _todoControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _todoChecked[index],
                        onChanged: _isLoading ? null : (value) {
                          setState(() {
                            _todoChecked[index] = value!;
                          });
                        },
                        shape: const CircleBorder(),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _todoControllers[index],
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: 'Masukkan item ${index + 1}',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            bool anyTodoFilled = _todoControllers.any((c) => c.text.trim().isNotEmpty);
                            if (!anyTodoFilled && (value == null || value.trim().isEmpty)) {
                              if (index == 0) { 
                                return 'Minimal satu item tugas wajib diisi';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: _isLoading ? null : () {
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
                                duration: const Duration(seconds: 2),
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () {
              setState(() {
                _todoControllers.add(TextEditingController());
                _todoChecked.add(false);
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalForm() {
    return Expanded(
      child: Column(
        children: [
          TextFormField(
            controller: _tanggalJadwalController,
            decoration: const InputDecoration(
              labelText: 'Tanggal',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            enabled: !_isLoading,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Tanggal wajib diisi'
                : null,
            onTap: () => _pickDate(_tanggalJadwalController),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _jamMulaiController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Mulai',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  enabled: !_isLoading,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Jam mulai wajib diisi'
                      : null,
                  onTap: () => _pickTime(_jamMulaiController),
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _jamSelesaiController,
                  decoration: const InputDecoration(
                    labelText: 'Jam Selesai',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  enabled: !_isLoading,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Jam selesai wajib diisi'
                      : null,
                  onTap: () => _pickTime(_jamSelesaiController),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextFormField(
              controller: _deskripsiJadwalController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              enabled: !_isLoading,
            ),
          ),
        ],
      ),
    );
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
              ? const Padding(
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
                  icon: const Icon(Icons.check),
                  tooltip: 'Simpan Perubahan',
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Judul wajib diisi' : null,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              if (widget.catatan == null)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _jenisCatatan,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Catatan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
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
                            for (int i = 0; i < 3; i++) {
                              _todoControllers.add(TextEditingController());
                              _todoChecked.add(false);
                            }
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
                    const SizedBox(height: 16),
                  ],
                ),

              if (_jenisCatatan == 'catatan')
                _buildCatatanForm()
              else if (_jenisCatatan == 'tugas')
                _buildTodoListForm()
              else if (_jenisCatatan == 'jadwal')
                _buildJadwalForm(),
            ],
          ),
        ),
      ),
    );
  }
}

//biar bisa comit