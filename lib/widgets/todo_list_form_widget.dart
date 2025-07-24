import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodoListFormWidget extends StatefulWidget {
  final List<TextEditingController> todoControllers;
  final List<bool> todoChecked;
  final bool isLoading;
  final Function(int) onRemoveItem;
  final Function(int) addEmptyTodoItems;
  final String jenisCatatan;


  const TodoListFormWidget({
    super.key,
    required this.todoControllers,
    required this.todoChecked,
    required this.isLoading,
    required this.onRemoveItem,
    required this.addEmptyTodoItems,
    required this.jenisCatatan,
  });

  @override
  State<TodoListFormWidget> createState() => _TodoListFormWidgetState();
}

class _TodoListFormWidgetState extends State<TodoListFormWidget> {
  @override
  Widget build(BuildContext context) {
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
              itemCount: widget.todoControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: widget.todoChecked[index],
                        onChanged: widget.isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  widget.todoChecked[index] = value!;
                                });
                              },
                        shape: const CircleBorder(),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: widget.todoControllers[index],
                          enabled: !widget.isLoading,
                          decoration: InputDecoration(
                            hintText: 'Masukkan item ${index + 1}',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (widget.jenisCatatan == 'tugas') {
                              bool anyTodoFilled = widget.todoControllers.any((c) => c.text.trim().isNotEmpty);
                              if (!anyTodoFilled) {
                                if (index == 0) {
                                  return 'Minimal satu item tugas wajib diisi';
                                }
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: widget.isLoading ? null : () => widget.onRemoveItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: widget.isLoading
                ? null
                : () {
                    setState(() {
                      widget.addEmptyTodoItems(1);
                    });
                  },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Item'),
          ),
        ],
      ),
    );
  }
}