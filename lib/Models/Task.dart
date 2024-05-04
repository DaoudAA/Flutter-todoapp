import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'TaskCategory.dart';
import 'TaskPriority.dart';

class Task {
  String id;
  String taskTitle;
  String taskDesc;
  String userId;
  TaskCategory category;
  TaskPriority priority;
  DateTime date;
  TimeOfDay time;
  bool isCompleted;

  Task({
    required this.id,
    required this.taskTitle,
    required this.taskDesc,
    required this.userId,
    required this.category,
    required this.priority,
    required this.date,
    required this.time,
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
    TimeOfDay? time,
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
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskTitle': taskTitle,
      'taskDesc': taskDesc,
      'userId': userId,
      'category': category.toString(),
      'priority': priority.toString(),
      'date': date.toIso8601String(),
      'time': time.toString(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Provide default values or handle null values
    final category = data['category'] != null ? TaskCategory.stringToTaskCategory(data['category']) : TaskCategory.others;
    final priority = data['priority'] != null ? TaskPriority.stringToTaskPriority(data['priority']) : TaskPriority.Low;
    final timestamp = data['date'] as Timestamp?; // Retrieve the Timestamp object
    final date = timestamp != null ? timestamp.toDate() : DateTime.now(); // Extract the DateTime from the Timestamp
    final time = timestamp != null ? TimeOfDay.fromDateTime(timestamp.toDate()) : TimeOfDay.now(); // Extract the TimeOfDay
    final isCompleted = data['isCompleted'] ?? false;

    return Task(
      id: doc.id,
      taskTitle: data['taskTitle'] ?? '',
      taskDesc: data['taskDesc'] ?? '',
      userId: data['userId'] ?? '',
      category: category,
      priority: priority,
      date: date,
      time: time,
      isCompleted: isCompleted,
    );
  }
}
