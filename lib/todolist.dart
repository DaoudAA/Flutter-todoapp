import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:todolist/Models/Task.dart';
import 'usefulwidgets/widgets.dart';
import 'utils/utils.dart';
import 'Detailscreen.dart';
import 'CRUDOperations.dart';
import 'package:gap/gap.dart';
final taskCRUDProvider = Provider<TaskCRUD>((ref) => TaskCRUD(ref));
final taskListProvider = StreamProvider<List<Task>>((ref) {
  final fireStore = FirebaseFirestore.instance;
  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserUid != null) {
    return fireStore
        .collection('tasks')
        .where('userId', isEqualTo: currentUserUid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Task.fromDocument(doc)).toList());
  } else {
    return Stream.value([]);
  }
});

class TodoListPage extends ConsumerWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Key centerKey = UniqueKey();
    final deviceSize = context.deviceSize;
    final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());
    final date = ref.watch(dateProvider);

    return Consumer(
      builder: (context, watch, child) {
        final taskList = watch.watch(taskListProvider);
        final inCompletedTasks = _incompletedTasks(taskList.value ?? [], date);
        final completedTasks = _completedTasks(taskList.value ?? [], date);
        return taskList.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (tasks) {
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
      },
    );
  }
}


/*Widget _buildItemRow(BuildContext context,WidgetRef ref, DocumentSnapshot task) {
    final t = task.data() as Map<String, dynamic>;

    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          showDialog(
            context: context,
            builder: (context) => EditTaskDialog(task: task),
          );
        } else if (direction == DismissDirection.endToStart) {
          await ref.read(taskCRUDProvider).deleteTask(context, task.id);
        }
        return false;
      },
      background: Container(
        color: Colors.cyan,
        child: const Icon(Icons.edit, color: Colors.deepPurple),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.deepPurple),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
      ),
      direction: DismissDirection.horizontal,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => DetailScreen(task: task),
          ));
        },
        child: Container(
          color: Color(0x9C8DB7EF),
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    t['taskTitle'],
                    style: TextStyle(fontSize: 24.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    t['taskDesc'],
                    style: TextStyle(fontSize: 13.0, color: Colors.grey),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }*/
List<Task> _incompletedTasks(List<Task> tasks, DateTime date) {
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