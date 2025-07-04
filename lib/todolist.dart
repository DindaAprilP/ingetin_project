import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AddToDoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AddToDoPage extends StatefulWidget {
  const AddToDoPage({super.key});

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  final TextEditingController titleController = TextEditingController();
  final List<TextEditingController> itemControllers = List.generate(3, (_) => TextEditingController());
  final List<bool> isChecked = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'To Do List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
             Text(
              'Tambahkan Judul',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 4),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Checkbox(
                        value: isChecked[index],
                        onChanged: (value) {
                          setState(() {
                            isChecked[index] = value!;
                          });
                        },
                        shape: CircleBorder(),
                      ),
                      Expanded(
                        child: TextField(
                          controller: itemControllers[index],
                          decoration: InputDecoration(
                            hintText: 'Masukkan list',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
