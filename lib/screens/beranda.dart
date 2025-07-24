import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
import 'edit_catatan.dart'; 

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> catatan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCatatan();
  }

  Future<void> loadCatatan() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await supabase
          .from('catatan_dengan_detail')
          .select()
          .eq('id_pengguna', supabase.auth.currentUser!.id)
          .order('diperbarui_pada', ascending: false);

      setState(() {
        catatan = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        "Error",
        "Gagal memuat catatan: $error", 
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> hapusCatatan(String idCatatan, String judul) async {
    bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text('Hapus Catatan'),
          content: Text('Apakah Anda yakin ingin menghapus "$judul"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:  Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child:  Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true) {
      try {
        await supabase.from('catatan').delete().eq('id', idCatatan);
        
        Get.snackbar(
          "Berhasil",
          "Catatan berhasil dihapus",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        loadCatatan(); 
      } catch (error) {
        Get.snackbar(
          "Error",
          "Gagal menghapus catatan: $error", 
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> navigateToEdit(Map<String, dynamic> item) async {
    final result = await Get.to(() => EditCatatan(catatan: item));
    if (result == true) {
      loadCatatan(); 
    }
  }

  void lihatDetailCatatan(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape:  RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8, 
          padding:  EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
               SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['judul'],
                      style:  TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context); 
                      navigateToEdit(item); 
                    },
                    icon:  Icon(Icons.edit),
                    tooltip: 'Edit Catatan',
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getJenisColor(item['jenis_catatan']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getJenisLabel(item['jenis_catatan']),
                  style:  TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
               SizedBox(height: 20),
              Expanded(
                child: _buildDetailContent(item),
              ),
              Text(
                'Diperbarui: ${_formatDateTimeToWIB(item['diperbarui_pada'])}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailContent(Map<String, dynamic> item) {
    switch (item['jenis_catatan']) {
      case 'catatan':
        return SingleChildScrollView(
          child: Text(
            item['isi_catatan'] ?? 'Tidak ada isi catatan',
            style:  TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      
      case 'jadwal':
        String formattedDate = '-';
        String formattedTimeRange = '-';

        final String? tanggalJadwalString = item['tanggal_jadwal']; 
        final String? jamMulaiString = item['jam_mulai'];         
        final String? jamSelesaiString = item['jam_selesai'];  

        if (tanggalJadwalString != null && tanggalJadwalString.isNotEmpty) {
          try {
            final DateTime dateOnlyUtc = DateTime.parse(tanggalJadwalString);
            final DateTime dateOnlyWib = dateOnlyUtc.add( Duration(hours: 7));
            formattedDate = DateFormat('dd/MM/yyyy').format(dateOnlyWib);
          } catch (e) {
            print('Error parsing tanggal_jadwal for display: $e');
            formattedDate = tanggalJadwalString; 
          }
        }
        
        if (tanggalJadwalString != null && tanggalJadwalString.isNotEmpty &&
            jamMulaiString != null && jamMulaiString.isNotEmpty &&
            jamSelesaiString != null && jamSelesaiString.isNotEmpty) {
          try {
            final List<String> startParts = jamMulaiString.split(':');
            final List<String> endParts = jamSelesaiString.split(':');
            final DateTime parsedDate = DateTime.parse(tanggalJadwalString);
            final DateTime startTimeUtc = DateTime.utc(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
              int.parse(startParts[0]), 
              int.parse(startParts[1]), 
            );

            final DateTime endTimeUtc = DateTime.utc(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
              int.parse(endParts[0]),
              int.parse(endParts[1]), 
            );

            final DateTime startTimeWib = startTimeUtc.add( Duration(hours: 7));
            final DateTime endTimeWib = endTimeUtc.add( Duration(hours: 7));
            formattedTimeRange = '${DateFormat('HH:mm').format(startTimeWib)} - ${DateFormat('HH:mm').format(endTimeWib)}';
          } catch (e) {
            print('Error processing jadwal time for WIB conversion: $e');
            formattedTimeRange = '$jamMulaiString - $jamSelesaiString (Format Error)'; 
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tanggal', formattedDate),
            _buildInfoRow('Jam', formattedTimeRange),
            if (item['deskripsi_jadwal'] != null && item['deskripsi_jadwal'].isNotEmpty)
              _buildInfoRow('Deskripsi', item['deskripsi_jadwal']),
          ],
        );
      
      case 'tugas':
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadItemTugas(item['id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return  Text('Tidak ada item tugas');
            }
            
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final tugas = snapshot.data![index];
                return ListTile(
                  leading: Icon(
                    tugas['sudah_selesai'] 
                        ? Icons.check_circle 
                        : Icons.radio_button_unchecked,
                    color: tugas['sudah_selesai'] 
                        ? Colors.green 
                        : Colors.grey,
                  ),
                  title: Text(
                    tugas['teks_tugas'],
                    style: TextStyle(
                      decoration: tugas['sudah_selesai'] 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                  ),
                );
              },
            );
          },
        );
      
      default:
        return  Text('Jenis catatan tidak dikenal');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style:  TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadItemTugas(String idCatatan) async {
    try {
      final response = await supabase
          .from('item_tugas')
          .select()
          .eq('id_catatan', idCatatan)
          .order('urutan');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("Error loading item tugas: $error");
      return [];
    }
  }

  Color _getJenisColor(String jenis) {
    switch (jenis) {
      case 'catatan':
        return Colors.blue;
      case 'tugas':
        return Colors.orange;
      case 'jadwal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getJenisLabel(String jenis) {
    switch (jenis) {
      case 'catatan':
        return 'CATATAN';
      case 'tugas':
        return 'TUGAS';
      case 'jadwal':
        return 'JADWAL';
      default:
        return 'LAINNYA';
    }
  }

  IconData _getJenisIcon(String jenis) {
    switch (jenis) {
      case 'catatan':
        return Icons.article;
      case 'tugas':
        return Icons.check_circle;
      case 'jadwal':
        return Icons.schedule;
      default:
        return Icons.note;
    }
  }

  String _formatDateTimeToWIB(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '-';
    try {
      final utcDateTime = DateTime.parse(dateTimeString).toUtc();
      final wibDateTime = utcDateTime.add( Duration(hours: 7));
      return DateFormat('dd/MM/yyyy HH:mm').format(wibDateTime) + ' WIB';
    } catch (e) {
      print("Error formatting date-time string '$dateTimeString' to WIB: $e");
      return dateTimeString; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.asset(
          'assets/tugas', 
          height: 30,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ?  Center(child: CircularProgressIndicator())
          : catatan.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          "assets/berandaKosong.png", 
                          width: 120,
                          height: 120,
                        ),
                      ),
                       SizedBox(height: 5),
                       Text("Belum Ada Catatan"),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadCatatan,
                  child: ListView.builder(
                    padding:  EdgeInsets.all(16),
                    itemCount: catatan.length,
                    itemBuilder: (context, index) {
                      final item = catatan[index];
                      return Container(
                        margin:  EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => lihatDetailCatatan(item),
                            child: Container(
                              padding:  EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding:  EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getJenisColor(item['jenis_catatan']),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getJenisIcon(item['jenis_catatan']),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                   SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['judul'],
                                          style:  TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                         SizedBox(height: 4),
                                        if (item['jenis_catatan'] == 'tugas')
                                          Text(
                                            '${item['tugas_selesai']}/${item['total_tugas']} selesai',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          )
                                        else if (item['jenis_catatan'] == 'jadwal' && item['tanggal_jadwal'] != null && item['tanggal_jadwal'].isNotEmpty)
                                          Text(
                                            DateFormat('dd/MM/yyyy').format(
                                              DateTime.parse(item['tanggal_jadwal'])
                                                  .toUtc()
                                                  .add( Duration(hours: 7)),
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          )
                                        else
                                          Text(
                                            _formatDateTimeToWIB(item['diperbarui_pada']),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.grey[600],
                                    ),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        navigateToEdit(item);
                                      } else if (value == 'delete') {
                                        hapusCatatan(item['id'], item['judul']);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                       PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                       PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, 
                                                  size: 20, 
                                                  color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Hapus', 
                                                  style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}