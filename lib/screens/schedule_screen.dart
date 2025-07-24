import 'package:flutter/material.dart';
import 'package:ingetin_project/widgets/navbottom.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:ingetin_project/services/auth_services.dart';
import 'package:ingetin_project/services/schedule_service.dart';

class ScheduleScreen extends StatefulWidget { 
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  final _authService = AuthService(); 
  final _scheduleService = ScheduleService(); 

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    if (!_authService.isAuthenticated()) {
      _showAuthDialog();
    }
  }

  void _showAuthDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Otentikasi Dibutuhkan'),
            content: const Text('Anda harus masuk untuk menyimpan jadwal.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101), 
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<TimeOfDay?> _showScrollTimePicker(
      BuildContext context, TimeOfDay initialTime) async {
    int selectedHour = initialTime.hour;
    int selectedMinute = initialTime.minute;

    final TimeOfDay? pickedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context,
                          TimeOfDay(hour: selectedHour, minute: selectedMinute));
                    },
                    child: Text('Selesai'),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CupertinoPicker(
                        scrollController:
                            FixedExtentScrollController(initialItem: selectedHour),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          selectedHour = index;
                        },
                        children: List<Widget>.generate(24, (int index) {
                          return Center(child: Text(index.toString().padLeft(2, '0')));
                        }),
                      ),
                    ),
                    Text(':', style: TextStyle(fontSize: 24)),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController:
                            FixedExtentScrollController(initialItem: selectedMinute),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          selectedMinute = index;
                        },
                        children: List<Widget>.generate(60, (int index) {
                          return Center(child: Text(index.toString().padLeft(2, '0')));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    return pickedTime;
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked =
        await _showScrollTimePicker(context, _startTime ?? TimeOfDay.now());
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked =
        await _showScrollTimePicker(context, _endTime ?? TimeOfDay.now());
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt); 
  }

  Future<void> _saveSchedule() async {
    if (!_authService.isAuthenticated()) {
      _showAuthDialog();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showSnackBar('Pilih Tanggal', Colors.red);
      return;
    }

    if (_startTime == null || _endTime == null) {
      _showSnackBar('Pilih Waktu Mulai dan Selesai', Colors.red);
      return;
    }

    final startDateTime = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, _startTime!.hour, _startTime!.minute);
    final endDateTime = DateTime(_selectedDate!.year, _selectedDate!.month,
        _selectedDate!.day, _endTime!.hour, _endTime!.minute);

    if (endDateTime.isBefore(startDateTime)) {
      _showSnackBar('Waktu selesai tidak boleh sebelum waktu mulai', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.getCurrentUser()!.id;

      await _scheduleService.createNewSchedule(
        userId: userId,
        judul: _nameController.text.trim(),
        tanggalJadwal: _selectedDate!,
        jamMulai: _formatTimeOfDay(_startTime!),
        jamSelesai: _formatTimeOfDay(_endTime!),
        deskripsi: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      _showSnackBar('Jadwal berhasil disimpan!', Colors.green);
      _resetForm();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) {
              return bottomNavigationBar(); 
            }),
      );
    } on PostgrestException catch (e) {
      _showSnackBar('Error database: ${e.message}', Colors.red);
    } catch (error) {
      _showSnackBar('Error menyimpan jadwal: ${error.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = null;
      _startTime = null;
      _endTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            'Tambah Jadwal Baru',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveSchedule,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Icon(Icons.check, color: Colors.white),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_authService.isAuthenticated()) 
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade700),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Anda perlu login untuk menyimpan jadwal',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
                Text(
                  'Nama Jadwal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan nama jadwal',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama jadwal tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Tanggal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                              : 'dd/mm/yyyy',
                          style: TextStyle(
                            color:
                                _selectedDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                        Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jam Mulai',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectStartTime(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _startTime != null
                                        ? _startTime!.format(context)
                                        : '00:00',
                                    style: TextStyle(
                                      color: _startTime != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  Icon(Icons.access_time,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jam Selesai',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectEndTime(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _endTime != null
                                        ? _endTime!.format(context)
                                        : '00:00',
                                    style: TextStyle(
                                      color: _endTime != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  Icon(Icons.access_time,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Deskripsi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan deskripsi jadwal (opsional)',
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}