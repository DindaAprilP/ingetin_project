import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CatatanListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final Function(String id, String judul) onDelete;
  final Function(Map<String, dynamic> item) onEdit;

  const CatatanListItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

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

  String _getTanggalJadwalPreview(Map<String, dynamic> item) {
    if (item['jenis_catatan'] == 'jadwal' && item['tanggal_jadwal'] != null && item['tanggal_jadwal'].isNotEmpty) {
      try {
        final DateTime dateOnlyUtc = DateTime.parse(item['tanggal_jadwal']);
        final DateTime dateOnlyWib = dateOnlyUtc.add(Duration(hours: 7));
        return DateFormat('dd/MM/yyyy').format(dateOnlyWib);
      } catch (e) {
        return item['tanggal_jadwal'];
      }
    }
    return _formatDateTimeToWIB(item['diperbarui_pada']);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      if (item['jenis_catatan'] == 'tugas')
                        Text(
                          '${item['tugas_selesai'] ?? 0}/${item['total_tugas'] ?? 0} selesai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      else if (item['jenis_catatan'] == 'jadwal')
                        Text(
                          _getTanggalJadwalPreview(item),
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
                      onEdit(item);
                    } else if (value == 'delete') {
                      onDelete(item['id'], item['judul']);
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
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
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
  }
}