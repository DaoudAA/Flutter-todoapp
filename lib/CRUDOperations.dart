import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist/Task.dart';
//import 'package:provider/provider.dart';
final taskListProvider = StateProvider<List<DocumentSnapshot>>((ref) => []);
final taskCRUDProvider = Provider<TaskCRUD>((ref) => TaskCRUD(ref));

class TaskCRUD {
  final Ref ref;

  TaskCRUD(this.ref);
  Future<void> fetchTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('tasks').where('userId', isEqualTo: user.uid).get();
      ref.read(taskListProvider.notifier).state = snapshot.docs;
    }
  }
  Future<void> addTask(BuildContext context, String title,
      String description) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newTaskDocument = await FirebaseFirestore.instance.collection(
          'tasks').add({
        'taskTitle': title,
        'taskDesc': description,
        'userId': user.uid,
      });
      final newTaskSnapshot = await newTaskDocument.get();
      ref
          .watch(taskListProvider.notifier)
          .state = [...ref
          .watch(taskListProvider.notifier)
          .state, newTaskSnapshot];
    }
  }

  Future<void> deleteTask(BuildContext context, String taskId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
    ref
        .watch(taskListProvider.notifier)
        .state =
        ref.watch(taskListProvider).where((task) => task.id != taskId).toList();
  }

  Future<void> updateTask(BuildContext context, String taskId, String newTitle, String newDescription) async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);
    final task = await taskRef.get();
    final currentTitle = task['taskTitle'];
    final currentDescription = task['taskDesc'];

    if (newTitle != currentTitle || newDescription != currentDescription) {
      await taskRef.update({
        'taskTitle': newTitle,
        'taskDesc': newDescription,
      });

      final updatedTask = await taskRef.get();
      final updatedList = ref.read(taskListProvider).map((doc) {
        if (doc.id == taskId) {
          return updatedTask;
        } else {
          return doc;
        }
      }).toList();

      ref.read(taskListProvider.notifier).state = updatedList;
    }else {
      ref.refresh(taskListProvider);
    }
  }
}
  class AddTaskDialog extends ConsumerWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text('Add Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = titleController.text;
            final description = descriptionController.text;
            ref.read(taskCRUDProvider).addTask(context, title, description);
            Navigator.pop(context);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class EditTaskDialog extends ConsumerWidget {
  final DocumentSnapshot task;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  EditTaskDialog({required this.task}) {
    titleController.text = task['taskTitle'];
    descriptionController.text = task['taskDesc'];
  }

  @override
  Widget build(BuildContext context,  WidgetRef ref) {
    return AlertDialog(
      title: Text('Edit Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Description'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ref.read(taskCRUDProvider).updateTask(context, task.id, task['taskTitle'], task['taskDesc']);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newTitle = titleController.text;
            final newDescription = descriptionController.text;
            ref.read(taskCRUDProvider).updateTask(context, task.id, newTitle, newDescription);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
