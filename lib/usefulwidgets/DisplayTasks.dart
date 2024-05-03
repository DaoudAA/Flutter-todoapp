

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist/CRUDOperations.dart';
import 'package:todolist/utils/extensions.dart';

import '../DetailScreen.dart';
import '../Models/Task.dart';

class DisplayTasks extends ConsumerWidget {
  const DisplayTasks({
    Key? key,
    required this.isCompletedTasks,
    required this.tasks,
  }) : super(key: key);

  final bool isCompletedTasks;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSize = context.deviceSize;
    final height = isCompletedTasks ? deviceSize.height * 0.25 : deviceSize.height * 0.3;
    final emptyTasksAlert =
    isCompletedTasks ? 'There is no completed task yet' : 'There is no task to do!';

    return Container(
      width: deviceSize.width,

      height: height,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: tasks.isEmpty
          ? Center(
        child: Text(
          emptyTasksAlert,
          style: context.textTheme.headlineSmall,
        ),
      )
          : ListView.separated(
        shrinkWrap: true,
        itemCount: tasks.length,
        padding: EdgeInsets.zero,
        itemBuilder: (ctx, index) {
          final task = tasks[index];
          final dateString = task.date.toString();
          return Dismissible(
            key: ValueKey(task.id),
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
            child: InkWell(
              /*onLongPress: () async {
                await AppAlerts.showAlertDeleteDialog(
                  context: context,
                  ref: ref,
                  task: task,
                );
              },*/
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    return DetailScreen(task: task);
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          task.taskTitle,
                          style: TextStyle(fontSize: 24.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          task.taskDesc,
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
        },
        separatorBuilder: (context, index) => const Divider(
          thickness: 1.5,
        ),
      ),
    );
  }
}
