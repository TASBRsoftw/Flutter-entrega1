import 'package:flutter/material.dart';
import '../models/category.dart' as mcat;
import '../services/database_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<mcat.Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _isLoading = true);
    _categories = DatabaseService.instance.getCategories();
    setState(() => _isLoading = false);
  }

  Future<void> _showEditDialog([mcat.Category? category]) async {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    Color selectedColor = category?.color ?? Colors.blue;
    final formKey = GlobalKey<FormState>();

    final colors = {
      'Azul': Colors.blue,
      'Verde': Colors.green,
      'Laranja': Colors.orange,
      'Vermelho': Colors.red,
      'Roxo': Colors.purple,
      'Cinza': Colors.grey,
    };

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Nova Categoria' : 'Editar Categoria'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: colors.entries.map((e) {
                  final c = e.value;
                  return ChoiceChip(
                    label: Text(e.key),
                    selected: selectedColor == c,
                    onSelected: (_) => setState(() => selectedColor = c),
                    backgroundColor: c.withOpacity(0.2),
                    selectedColor: c.withOpacity(0.4),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = nameCtrl.text.trim();
              if (category == null) {
                // create
                await DatabaseService.instance.createCategory(mcat.Category(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, color: selectedColor));
              } else {
                await DatabaseService.instance.updateCategory(mcat.Category(id: category.id, name: name, color: selectedColor));
              }
              Navigator.pop(context, true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) _load();
  }

  Future<void> _confirmDelete(mcat.Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: Text('Excluir "${category.name}"? Isso removerá a categoria das tarefas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.instance.deleteCategory(category.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = _categories[index];
                return ListTile(
                  leading: CircleAvatar(backgroundColor: c.color),
                  title: Text(c.name),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(onPressed: () => _showEditDialog(c), icon: const Icon(Icons.edit)),
                    IconButton(onPressed: () => _confirmDelete(c), icon: const Icon(Icons.delete), color: Colors.red),
                  ]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
