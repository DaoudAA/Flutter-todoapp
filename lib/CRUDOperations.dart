// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:todolist/Models/Task.dart';
import 'package:todolist/utils/extensions.dart';

import 'Models/TaskCategory.dart';

import 'utils/helpers.dart';

//extends StateNotifier<List<Task>>
/*class TaskRepository  {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final currentUserUid = _auth.currentUser?.uid;
    if (currentUserUid != null) {
  Stream<List<Task>> get tasksStream => _firestore
          .collection('tasks')
          .where('userId', isEqualTo: currentUserUid)
          .snapshots()
          .map(
                (doc) => Task.fromFirestore(doc),
          )
      .toList(),
    }
  }

  Future<void> addTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('tasks').add(task.toJson());
    }
  }

  Future<void> updateTask(Task task) async {
    final taskRef = _firestore.collection('tasks').doc(task.id);
    await taskRef.update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final taskNotifier = TaskNotifier();
  taskNotifier.fetchTasks();
  return taskNotifier;
});*/
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
  Future<void> addTask(BuildContext context, Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newTaskDocument = await FirebaseFirestore.instance.collection('tasks').add(task.toJson());
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

  Future<void> updateTask(BuildContext context, Task task) async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(task.id);

    final taskData = task.toJson();
    taskData.remove('id');
    taskData.remove('userId');
    await taskRef.update(taskData);

      final updatedTask = await taskRef.get();
      final updatedList = ref.read(taskListProvider).map((doc) {
        if (doc.id == task.id) {
          return updatedTask;
        } else {
          return doc;
        }
      }).toList();

      ref.read(taskListProvider.notifier).state = updatedList;

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
            //ref.read(taskCRUDProvider).addTask(context, title, description);
            Navigator.pop(context);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
/*class TaskListRepository {

  final TaskNotifier _taskNotifier;

  TaskListRepository(this._taskNotifier);

  Future<void> addTask(Task task) async {
    await _taskNotifier.addTask(task);
    _taskNotifier.fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    await _taskNotifier.updateTask(task);
    _taskNotifier.fetchTasks();
    //ref.read(taskListProvider.notifier).state = [...ref.read(taskListProvider.notifier).state, task];
  }

  Future<void> deleteTask(String taskId) async {
    await _taskNotifier.deleteTask(taskId);
    _taskNotifier.fetchTasks();
    //ref.read(taskListProvider.notifier).state = ref.read(taskListProvider.notifier).state.where((task) => task.id != taskId).toList();
  }

  Stream<List<Task>> getTaskStream() {
    return _taskNotifier.stream;
  }
}*/
final categoryProvider = StateProvider.autoDispose<TaskCategory?>((ref) {
  return TaskCategory.others;
});
final dateProvider1 = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
final timeProvider = StateProvider.autoDispose<TimeOfDay>((ref) {
  return TimeOfDay.now();
});
class EditTaskDialogWrapper extends StatefulWidget {
  final Task task;
  final Function(Task) onSave;

  EditTaskDialogWrapper({required this.task, required this.onSave});

  @override
  _EditTaskDialogWrapperState createState() => _EditTaskDialogWrapperState();
}

class _EditTaskDialogWrapperState extends State<EditTaskDialogWrapper> {
  late final titleController = TextEditingController()..text = widget.task.taskTitle;
  late final descriptionController = TextEditingController()..text = widget.task.taskDesc;
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return EditTaskDialog(
      task: widget.task,
      onSave: (Task updatedTask) {
        widget.onSave(updatedTask);
      },
      titleController: titleController,
      descriptionController: descriptionController,
    );
  }
}

class EditTaskDialog extends ConsumerWidget{
  final Task task;
  final Function(Task) onSave;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  EditTaskDialog({
    required this.task,
    required this.onSave,
    required this.titleController,
    required this.descriptionController,
  });



  @override
  Widget build(BuildContext context,  WidgetRef ref) {

    return  Container(
      padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Edit Task',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Task Title',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  TextField(
                    controller: titleController,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    maxLines: null,
                    autocorrect: false,
                    decoration: InputDecoration(
                      filled:true,
                      fillColor: Colors.deepPurple.shade400.withOpacity(0.1),
                      hintText: 'Task Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade400,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Task Description',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  TextField(
                    controller: descriptionController,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    maxLines: null,
                    autocorrect: false,
                    decoration: InputDecoration(
                      filled:true,
                      fillColor: Colors.deepPurple.shade400.withOpacity(0.1),
                      hintText: 'Task Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade400,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Text(
                          'Category',
                          style: context.textTheme.titleMedium,
                        ),
                        const Gap(10),
                        Expanded(
                          child: ListView.separated(
                            itemCount: TaskCategory.values.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (ctx, index) {
                              final category = TaskCategory.values[index];
                              final selectedCategory = ref.watch(categoryProvider);

                              return InkWell(
                                onTap: () {
                                  ref.read(categoryProvider.notifier).state = category;
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: category.color.withOpacity(0.3),
                                    border: Border.all(
                                      width: 2,
                                      color: category.color.withOpacity(1),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      category.icon,
                                      color: selectedCategory == category
                                          ? context.colorScheme.primary
                                          : category.color.withOpacity(1),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => const Gap(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Date',
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              readOnly: true,
                              onTap: () => _selectDate(context, ref ),
                              autocorrect: false,
                              controller: null,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.deepPurple.shade400.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple.shade400,
                                    width: 2.0,
                                  ),
                                ),
                                hintText: Helpers.dateFormatter(ref.watch(dateProvider1)),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      _selectDate(context, ref ),
                                  icon: const Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Time',
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              readOnly: true,
                              onTap: () =>
                                  _selectTime(context, ref ),
                              autocorrect: false,
                              controller: null,
                              decoration: InputDecoration(
                                filled:true,
                                fillColor: Colors.deepPurple.shade400.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple.shade400,
                                    width: 2.0,
                                  ),
                                ),
                                hintText: Helpers.timeToString(
                                    ref.watch(timeProvider)),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      _selectTime(context, ref ),
                                  icon: const Icon(Icons.access_time),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(taskCRUDProvider).updateTask(context, task);
                        },
                        child: Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final newTitle = titleController.text.trim();
                          final newDescription = descriptionController.text.trim();
                          final updatedTask = task.copyWith(
                            taskTitle: newTitle,
                            taskDesc: newDescription,
                            category: ref.watch(categoryProvider),
                            date: DateTime(
                              ref.watch(dateProvider1).year,
                              ref.watch(dateProvider1).month,
                              ref.watch(dateProvider1).day,
                              ref.watch(timeProvider).hour,
                              ref.watch(timeProvider).minute,
                            ),
                          );
                          await ref
                              .read(taskCRUDProvider)
                              .updateTask(context, updatedTask);
                          Navigator.pop(context);
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  void _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: ref.watch(dateProvider1),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      ref.read(dateProvider1.notifier).state = pickedDate;
    }
  }

  void _selectTime(BuildContext context, WidgetRef ref) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: ref.watch(timeProvider),
    );
    if (pickedTime != null) {
      ref.read(timeProvider.notifier).state = pickedTime;
    }
  }
}
