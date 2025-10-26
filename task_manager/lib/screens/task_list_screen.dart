import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../models/category.dart' as mcat;
import '../widgets/task_card.dart';
import 'category_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  String _filter = 'all'; // all, completed, pending
  String _categoryFilter = 'all';
  List<mcat.Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await DatabaseService.instance.readAll();
    final cats = DatabaseService.instance.getCategories();
    if (mounted) setState(() {
      _tasks = tasks;
      _categories = cats;
      _isLoading = false;
    });

    // show alert if there are overdue tasks
    final overdueCount = tasks.where((t) => t.dueDate != null && !t.completed && t.dueDate!.isBefore(DateTime.now())).length;
    if (overdueCount > 0 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Você tem $overdueCount tarefa(s) vencida(s)'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ));
      });
    }
  }

  List<Task> get _filteredTasks {
    var tasks = _tasks;
    switch (_filter) {
      case 'completed':
        tasks = tasks.where((t) => t.completed).toList();
        break;
      case 'pending':
        tasks = tasks.where((t) => !t.completed).toList();
        break;
    }

    if (_categoryFilter != 'all') {
      tasks = tasks.where((t) => t.categoryId == _categoryFilter).toList();
    }

    // order by dueDate (earliest first), nulls last
    tasks.sort((a, b) {
      if (a.dueDate != null && b.dueDate != null) return a.dueDate!.compareTo(b.dueDate!);
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return tasks;
  }

  Future<void> _toggleTask(Task task) async {
    final updated = task.copyWith(completed: !task.completed);
    await DatabaseService.instance.update(updated);
    await _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.instance.delete(task.id);
      await _loadTasks();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarefa excluída'), duration: Duration(seconds: 2)));
    }
  }

  Future<void> _openTaskForm([Task? task]) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => TaskFormScreen(task: task)));
    if (result == true) await _loadTasks();
  }

  Map<String, int> _calculateStats() {
    return {
      'total': _tasks.length,
      'completed': _tasks.where((t) => t.completed).length,
      'pending': _tasks.where((t) => !t.completed).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;
    final stats = _calculateStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('Todas')),
              PopupMenuItem(value: 'pending', child: Text('Pendentes')),
              PopupMenuItem(value: 'completed', child: Text('Concluídas')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.category),
            onSelected: (value) => setState(() => _categoryFilter = value),
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];
              items.add(const PopupMenuItem(value: 'all', child: Text('Todas as categorias')));
              items.addAll(_categories.map((c) => PopupMenuItem(value: c.id, child: Row(children: [Icon(Icons.label, color: c.color), const SizedBox(width:8), Text(c.name)]))));
              return items;
            },
          ),
          IconButton(onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen()));
            await _loadTasks();
          }, icon: const Icon(Icons.manage_accounts)),
        ],
      ),
      body: Column(
        children: [
          if (_tasks.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.list, 'Total', stats['total'].toString()),
                  _buildStatItem(Icons.check_circle, 'Concluídas', stats['completed'].toString()),
                  _buildStatItem(Icons.pending, 'Pendentes', stats['pending'].toString()),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadTasks,
                    child: filteredTasks.isEmpty ? _buildEmptyState() : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final t = filteredTasks[index];
                        final cat = DatabaseService.instance.getCategoryById(t.categoryId);
                        return TaskCard(
                          task: t,
                          onTap: () => _openTaskForm(t),
                          onToggle: () => _toggleTask(t),
                          onDelete: () => _deleteTask(t),
                          categoryName: cat?.name,
                          categoryColor: cat?.color,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa'),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    switch (_filter) {
      case 'completed':
        message = 'Nenhuma tarefa concluída ainda';
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
        message = 'Nenhuma tarefa pendente';
        icon = Icons.pending_actions;
        break;
      default:
        message = 'Nenhuma tarefa cadastrada';
        icon = Icons.task_alt;
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            TextButton.icon(onPressed: () => _openTaskForm(), icon: const Icon(Icons.add), label: const Text('Criar primeira tarefa')),
          ],
        ),
      ),
    );
  }
}
