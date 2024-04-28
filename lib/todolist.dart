import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/utils.dart';
import 'Detailscreen.dart';
import 'CRUDOperations.dart';
final taskCRUDProvider = Provider<TaskCRUD>((ref) => TaskCRUD(ref));
final taskListProvider = StreamProvider<List<DocumentSnapshot>>((ref) {
  final fireStore = FirebaseFirestore.instance;
  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserUid != null) {
    return fireStore.collection('tasks').where('userId', isEqualTo: currentUserUid).snapshots().map((snapshot) => snapshot.docs);
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
    return Consumer(
      builder: (context, watch, child) {
        final taskList = watch.watch(taskListProvider);
        return taskList.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (tasks) {
            return Scaffold(
              body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: deviceSize.width,
                      height: deviceSize.height * 0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _buildItemRow(context, ref, task);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'list_fab',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Swipe Actions'),
                            content: Text(
                              'Swipe right to update the task\nSwipe left to delete the task',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    tooltip: 'Swipe Actions',
                    child: Icon(Icons.lightbulb),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'dialog_fab',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddTaskDialog(),
                      );
                    },
                    tooltip: 'Add Task',
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  }

  Widget _buildItemRow(BuildContext context,WidgetRef ref, DocumentSnapshot task) {
    final t = task.data() as Map<String, dynamic>;

    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async  {
        if (direction == DismissDirection.startToEnd) {
          showDialog(
            context: context,
            builder: (context) => EditTaskDialog(task: task),
          );
        } else if (direction == DismissDirection.endToStart) {
          ref.read(taskCRUDProvider).deleteTask(context, task.id);
          }
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
          color: Colors.purple.withOpacity(0.1),
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
  }

