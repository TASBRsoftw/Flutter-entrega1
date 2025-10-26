class Task {
  final int? id;
  final String title;
  final String description;
  final bool completed;
  final String priority; // low, medium, high, urgent
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? categoryId;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    this.priority = 'medium',
    DateTime? createdAt,
    this.dueDate,
    this.categoryId,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    String? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    String? categoryId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'categoryId': categoryId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      completed: json['completed'] ?? false,
      priority: json['priority'] ?? 'medium',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      categoryId: json['categoryId'],
    );
  }
}
