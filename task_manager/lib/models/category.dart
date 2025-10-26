import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;

  Category({required this.id, required this.name, required this.color});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.value,
      };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      color: Color((json['color'] ?? Colors.grey.value) as int),
    );
  }
}
