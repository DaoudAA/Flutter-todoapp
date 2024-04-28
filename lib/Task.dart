import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String taskTitle;
  String taskDesc;
  String userId;
  String category;
  String priority;

  Task({
    required this.id,
    required this.taskTitle,
    required this.taskDesc,
    required this.userId,
    required this.category,
    required this.priority,
  });

  Task copyWith({
    String? id,
    String? taskTitle,
    String? taskDesc,
    String? userId,
    String? category,
    String? priority,
  }) {
    return Task(
      id: id ?? this.id,
      taskTitle: taskTitle ?? this.taskTitle,
      taskDesc: taskDesc ?? this.taskDesc,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      priority: priority ?? this.priority,
    );
  }


  factory Task.fromDocument(DocumentSnapshot doc) {
    return Task(
      id: doc.id,
      taskTitle: doc['taskTitle'],
      taskDesc: doc['taskDesc'],
      userId: doc['userId'],
      category: doc['category'],
      priority: doc['priority'],
    );
  }
}

class GroupedTask {
  String title;
  List<Task> tasks;

  GroupedTask({required this.title, required this.tasks});
}

List<GroupedTask> _getGroupedTasks(List<Task> tasksList) {
  Map<String, List<Task>> groupedTasks = {};

  for (Task task in tasksList) {
    if (!groupedTasks.containsKey(task.category)) {
      groupedTasks[task.category] = [];
    }
    groupedTasks[task.category]!.add(task);
  }

  return groupedTasks.entries.map((entry) => GroupedTask(title: entry.key, tasks: entry.value)).toList();
}