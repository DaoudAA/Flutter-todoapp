

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:todolist/CRUDOperations.dart';
import 'package:todolist/utils/extensions.dart';

import '../DetailScreen.dart';
import '../Models/Task.dart';

class DisplayTasks extends ConsumerWidget {
  const DisplayTasks({
    super.key,
    this.isCompletedTasks = false,
    required this.tasks,
  });
    //required this.onCompleted

  final bool isCompletedTasks;
  final List<Task> tasks;
  //final Function(bool?)? onCompleted;
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
        color: Colors.purple.shade50,
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
          print('${task.taskTitle} ${task.category.toString()}');
          final dateString = task.date.toString();
          final textDecoration =
          task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none;

          return InkWell(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                builder: (ctx) {
                  return DetailScreen(task: task);
                },
              );
            },
            child: Dismissible(
              key: ValueKey(task.id),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.66,
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(25.0),
                          topRight: const Radius.circular(25.0),
                        ),
                      ),
                      child: EditTaskDialogWrapper(
                        task: task,
                        onSave: (updatedTask) {
                          ref.read(taskCRUDProvider).updateTask(context, updatedTask);
                        },)
                    ),
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
              child:  Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.category.color.withOpacity(0.3),
                          border: Border.all(
                            width: 2,
                            color: task.category.color.withOpacity(1),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            task.category.icon,
                            color: task.category.color.withOpacity(0.5),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.taskTitle,
                              style: TextStyle(fontSize: 20.0,decoration: textDecoration),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '${task.date.hour}:${task.date.minute}',
                              // to format the date into timetask.date.toString(),
                              style: TextStyle(fontSize: 13.0, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: task.isCompleted,
                          onChanged: (value) {
                            print('Checkbox state changed: $value');
                            final updatedTask = task.copyWith(isCompleted: value ?? false);
                            print('${updatedTask.isCompleted}');
                            ref.read(taskCRUDProvider).updateTask(context, updatedTask);
                          },
                          checkColor: Colors.deepPurple.shade200
                      ),
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
