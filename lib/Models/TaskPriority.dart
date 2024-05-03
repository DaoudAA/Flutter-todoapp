import 'package:flutter/material.dart';

enum TaskPriority {
  Low(Icons.low_priority, Colors.greenAccent),
  High(Icons.priority_high,Colors.redAccent),
  Medium(Icons.priority_high_rounded,Colors.orangeAccent);
  static TaskPriority stringToTaskPriority(String lvl) {
  try {
    return TaskPriority.values.firstWhere(
          (priority) => priority.name == lvl,
    );
  } catch (e) {
    return TaskPriority.Low;
  }
}
final IconData icon;
final Color color;
const TaskPriority(this.icon, this.color);
}
