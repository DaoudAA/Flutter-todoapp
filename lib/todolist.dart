import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolist/Models/Task.dart';
import 'package:todolist/main_activity.dart';
import 'usefulwidgets/widgets.dart';
import 'utils/utils.dart';
import 'CRUDOperations.dart';
import 'package:gap/gap.dart';
final taskCRUDProvider = Provider<TaskCRUD>((ref) => TaskCRUD(ref));
/*final taskListProvider = StreamProvider<List<Task>>((ref) {
  final fireStore = FirebaseFirestore.instance;
  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserUid != null) {
    return fireStore
        .collection('tasks')
        .where('userId', isEqualTo: currentUserUid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  } else {
    return Stream.value([]);
  }
});*/
final taskListProvider = StreamProvider<List<Task>>((ref) {
  //print('taskListProvider: Started');
  final fireStore = FirebaseFirestore.instance;
  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  print('taskListProvider: currentUserUid = $currentUserUid');
  if (currentUserUid!= null) {
    print('taskListProvider: Getting tasks for user $currentUserUid');
    return fireStore
        .collection('tasks')
        .where('userId', isEqualTo: currentUserUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);
      }).toList();
    });
  } else {
    //print('taskListProvider: No user logged in, returning empty list');
    return Stream.value([]);
  }
});
class TodoListPage extends ConsumerWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskList = ref.watch(taskListProvider);


    return taskList.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (tasks) {
        final date = ref.watch(dateProvider);
        final inCompletedTasks = _incompletedTasks(tasks, date);
        final completedTasks = _completedTasks(tasks, date);
        return SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(17),
            child: Column(
              children: [
                DisplayTasks(
                  isCompletedTasks: false,
                  tasks: inCompletedTasks,
                ),
                const Gap(20),
                Text(
                  'Completed',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(20),
                DisplayTasks(
                  isCompletedTasks: true,
                  tasks: completedTasks,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
List<Task> _incompletedTasks(List<Task> tasks, DateTime date) {
  print('$date.toString() ---------------------------------------------------------');
  return tasks.where((task) => !_isCompleted(task) && _isTaskFromSelectedDate(task, date)).toList();
}

List<Task> _completedTasks(List<Task> tasks, DateTime date) {
  return tasks.where((task) => _isCompleted(task) && _isTaskFromSelectedDate(task, date)).toList();
}

bool _isCompleted(Task task) {
  return task.isCompleted;
}
bool _isTaskFromSelectedDate(Task task, DateTime selectedDate) {
  final DateTime taskDate = task.date ;
  return taskDate.month == selectedDate.month &&
      taskDate.year == selectedDate.year &&
      taskDate.day == selectedDate.day;
}