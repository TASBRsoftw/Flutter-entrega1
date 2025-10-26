import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/category.dart' as mcat;
import '../services/database_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'medium';
  bool _completed = false;
  bool _isLoading = false;
  String? _categoryId;
  DateTime? _dueDate;
  List<mcat.Category> _categories = [];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _priority = widget.task!.priority;
      _completed = widget.task!.completed;
      _categoryId = widget.task!.categoryId;
      _dueDate = widget.task!.dueDate;
    }
    // load categories
    _categories = DatabaseService.instance.getCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _dueDate != null ? TimeOfDay.fromDateTime(_dueDate!) : TimeOfDay.now(),
    );

    final picked = DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
    setState(() => _dueDate = picked);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final messenger = ScaffoldMessenger.of(context);
    try {
      if (widget.task == null) {
        final newTask = Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          completed: _completed,
          dueDate: _dueDate,
          categoryId: _categoryId,
        );
        await DatabaseService.instance.create(newTask);

        if (mounted) {
          messenger.showSnackBar(const SnackBar(
            content: Text('✓ Tarefa criada com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ));
        }
      } else {
        final updated = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _priority,
          completed: _completed,
          dueDate: _dueDate,
          categoryId: _categoryId,
        );
        await DatabaseService.instance.update(updated);

        if (mounted) {
          messenger.showSnackBar(const SnackBar(
            content: Text('✓ Tarefa atualizada com sucesso'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ));
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Título é obrigatório';
                        }
                        if (value.trim().length < 3) {
                          return 'Digite ao menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _priority,
                      decoration: const InputDecoration(labelText: 'Prioridade'),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Baixa')),
                        DropdownMenuItem(value: 'medium', child: Text('Média')),
                        DropdownMenuItem(value: 'high', child: Text('Alta')),
                        DropdownMenuItem(value: 'urgent', child: Text('Urgente')),
                      ],
                      onChanged: (v) => setState(() => _priority = v ?? 'medium'),
                    ),
                    const SizedBox(height: 8),
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                    const SizedBox(height: 8),
                    // Due date picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Data de Vencimento'),
                      subtitle: Text(_dueDate != null ? '${_dueDate!.day.toString().padLeft(2,'0')}/${_dueDate!.month.toString().padLeft(2,'0')}/${_dueDate!.year} ${_dueDate!.hour.toString().padLeft(2,'0')}:${_dueDate!.minute.toString().padLeft(2,'0')}' : 'Nenhuma'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_dueDate != null)
                            IconButton(onPressed: () => setState(() => _dueDate = null), icon: const Icon(Icons.clear)),
                          IconButton(onPressed: _pickDueDate, icon: const Icon(Icons.calendar_today)),
                        ],
                      ),
                    ),

                    SwitchListTile(
                      title: const Text('Concluída'),
                      value: _completed,
                      onChanged: (v) => setState(() => _completed = v),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveTask,
                      child: Text(isEditing ? 'Atualizar Tarefa' : 'Criar Tarefa'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
