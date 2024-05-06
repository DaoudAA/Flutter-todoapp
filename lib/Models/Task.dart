import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'TaskCategory.dart';
import 'TaskPriority.dart';

class Task {
  final  String id;
  final String taskTitle;
  final String taskDesc;
  final String userId;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime date;
  final bool isCompleted;

  Task({
    required this.id,
    required this.taskTitle,
    required this.taskDesc,
    required this.userId,
    required this.category,
    required this.priority,
    required this.date,
    required this.isCompleted,
  });

  Task copyWith({
    String? id,
    String? taskTitle,
    String? taskDesc,
    String? userId,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? date,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      taskTitle: taskTitle ?? this.taskTitle,
      taskDesc: taskDesc ?? this.taskDesc,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskTitle': taskTitle,
      'taskDesc': taskDesc,
      'userId': userId,
      'category': category.toString(),
      'priority': priority.toString(),
      'date': Timestamp.fromDate(date),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic>? map = doc.data() as Map<String, dynamic>?;

    if (map == null) {
      throw Exception('Failed to load task from Firestore');
    }

    map.forEach((key, value) {
      print('$key: $value');
    });

    final categoryString = map['category'] as String?;
    TaskCategory category;
    if (categoryString!= null) {
      category = TaskCategory.values.firstWhere(
            (element) => element.toString() == categoryString,
        orElse: () => TaskCategory.others,
      );
    } else {
      category = TaskCategory.others;
    }

    TaskPriority priority;
    final priorityString = map['priority'] as String?;
    if (priorityString!= null) {
      // You should handle priority string to TaskPriority conversion
      priority = TaskPriority.Low; // Default priority
    } else {
      priority = TaskPriority.Low; // Default priority
    }

    return Task(
      id: doc.id,
      taskTitle: map['taskTitle']?? '',
      taskDesc: map['taskDesc']?? '',
      userId: map['userId']?? '',
      category: category,
      priority: priority,
      date: (map['date'] as Timestamp?)?.toDate()?? DateTime.now(),
      isCompleted: map['isCompleted']?? false,
    );
  }

}
