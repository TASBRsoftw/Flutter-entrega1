import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'storage.dart';

import '../models/task.dart';
import '../models/category.dart' as mcat;

class DatabaseService {
  DatabaseService._privateConstructor();

  static final DatabaseService instance = DatabaseService._privateConstructor();

  final List<Task> _store = [];
  int _nextId = 1;
  final List<mcat.Category> _categories = [
    mcat.Category(id: 'work', name: 'Trabalho', color: Colors.blue),
    mcat.Category(id: 'personal', name: 'Pessoal', color: Colors.green),
    mcat.Category(id: 'shopping', name: 'Compras', color: Colors.orange),
  ];
  // storage is provided by storage.dart (file on IO platforms, localStorage on web)

  Future<Task> create(Task task) async {
    // simulate small delay
    await Future.delayed(const Duration(milliseconds: 100));
    final newTask = task.copyWith(id: _nextId++);
    _store.add(newTask);
    await _saveToFile();
    return newTask;
  }

  Future<List<Task>> readAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // return copy; sorting will usually be done by caller but provide a sensible default
    final list = List<Task>.from(_store);
    // sort by dueDate (earliest first), tasks without dueDate go after, then by createdAt desc
    list.sort((a, b) {
      if (a.dueDate != null && b.dueDate != null) {
        final cmp = a.dueDate!.compareTo(b.dueDate!);
        if (cmp != 0) return cmp;
      } else if (a.dueDate != null) {
        return -1; // a before b
      } else if (b.dueDate != null) {
        return 1; // b before a
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  /// Initialize persistence (call once on app startup)
  Future<void> init() async {
    try {
      await initStorage();
      if (await storageExists()) {
        final text = await readStorage();
        if (text != null && text.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(text);
          // load categories
          final cats = (data['categories'] as List<dynamic>?) ?? [];
          _categories.clear();
          for (final c in cats) {
            _categories.add(mcat.Category.fromJson(Map<String, dynamic>.from(c)));
          }
          // load tasks
          final tasksJson = (data['tasks'] as List<dynamic>?) ?? [];
          _store.clear();
          for (final t in tasksJson) {
            final task = Task.fromJson(Map<String, dynamic>.from(t));
            _store.add(task);
            if (task.id != null && task.id! >= _nextId) _nextId = task.id! + 1;
          }
        }
      } else {
        await _saveToFile();
      }
    } catch (e) {
      if (kDebugMode) print('Failed to init storage: $e');
    }
  }

  Future<void> _saveToFile() async {
    final data = {
      'categories': _categories.map((c) => c.toJson()).toList(),
      'tasks': _store.map((t) => t.toJson()).toList(),
    };
    try {
      await writeStorage(jsonEncode(data));
    } catch (e) {
      if (kDebugMode) print('Failed to write storage: $e');
    }
  }

  /// Return configured categories
  List<mcat.Category> getCategories() => List.unmodifiable(_categories);

  mcat.Category? getCategoryById(String? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Category CRUD
  Future<mcat.Category> createCategory(mcat.Category category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    // ensure id unique
    final id = category.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : category.id;
    final newCat = mcat.Category(id: id, name: category.name, color: category.color);
    _categories.add(newCat);
    await _saveToFile();
    return newCat;
  }

  Future<void> updateCategory(mcat.Category category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx != -1) {
      _categories[idx] = category;
      await _saveToFile();
    }
  }

  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _categories.removeWhere((c) => c.id == id);
    // Also clear categoryId from tasks that used it
    for (var i = 0; i < _store.length; i++) {
      final t = _store[i];
      if (t.categoryId == id) {
        _store[i] = t.copyWith(categoryId: null);
      }
    }
    await _saveToFile();
  }

  Future<void> update(Task task) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _store.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      _store[idx] = task;
      await _saveToFile();
    } else {
      if (kDebugMode) {
        print('DatabaseService.update: task not found id=${task.id}');
      }
    }
  }

  Future<void> delete(int? id) async {
    if (id == null) return;
    await Future.delayed(const Duration(milliseconds: 100));
    _store.removeWhere((t) => t.id == id);
    await _saveToFile();
  }
}
