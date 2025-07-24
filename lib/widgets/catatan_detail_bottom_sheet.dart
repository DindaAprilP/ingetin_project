import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/dashboard_service.dart'; 
import '../services/catatan_service.dart'; 

class CatatanDetailBottomSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final Function(Map<String, dynamic> item) onEditCallback;

  const CatatanDetailBottomSheet({
    super.key,
    required this.item,
    required this.onEditCallback,
  });

  @override
  State<CatatanDetailBottomSheet> createState() => _CatatanDetailBottomSheetState();
}

class _CatatanDetailBottomSheetState extends State<CatatanDetailBottomSheet> {
  final DashboardService _dashboardService = DashboardService();
  final CatatanService _catatanService = CatatanService(); 

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.all(20),
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
                  widget.item['judul'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context); 
                  widget.onEditCallback(widget.item); 
                },
                icon: Icon(Icons.edit),
                tooltip: 'Edit Catatan',
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getJenisColor(widget.item['jenis_catatan']),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getJenisLabel(widget.item['jenis_catatan']),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _buildDetailContent(widget.item),
          ),
          Text(
            'Diperbarui: ${_formatDateTimeToWIB(widget.item['diperbarui_pada'])}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(Map<String, dynamic> item) {
    switch (item['jenis_catatan']) {
      case 'catatan':
        return SingleChildScrollView(
          child: Text(
            item['isi_catatan'] ?? 'Tidak ada isi catatan',
            style: TextStyle(fontSize: 16, height: 1.5),
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
            final DateTime dateOnlyWib = dateOnlyUtc.add(Duration(hours: 7));
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

            final DateTime startTimeWib = startTimeUtc.add(Duration(hours: 7));
            final DateTime endTimeWib = endTimeUtc.add(Duration(hours: 7));
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
          future: _dashboardService.getItemTugasForDetail(item['id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('Tidak ada item tugas');
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
        return Text('Jenis catatan tidak dikenal');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
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

  String _formatDateTimeToWIB(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '-';
    try {
      final utcDateTime = DateTime.parse(dateTimeString).toUtc();
      final wibDateTime = utcDateTime.add(Duration(hours: 7));
      return DateFormat('dd/MM/yyyy HH:mm').format(wibDateTime) + ' WIB';
    } catch (e) {
      print("Error formatting date-time string '$dateTimeString' to WIB: $e");
      return dateTimeString;
    }
  }
}