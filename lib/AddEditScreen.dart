import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:todolist/CRUDOperations.dart';
import 'package:todolist/Models/TaskPriority.dart';
import 'package:todolist/usefulwidgets/widgets.dart';
import 'package:todolist/utils/utils.dart';

import 'Models/Task.dart';
import 'Models/TaskCategory.dart';

class CreateTaskScreen extends ConsumerWidget {
  final taskListProvider = StateProvider<List<DocumentSnapshot>>((ref) => []);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final categoryProvider = StateProvider.autoDispose<TaskCategory?>((ref) {
    return TaskCategory.others;
  });
  final dateProvider = StateProvider<DateTime>((ref) {
    return DateTime.now();
  });
  final timeProvider = StateProvider.autoDispose<TimeOfDay>((ref) {
    return TimeOfDay.now();
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade300,
        title: const DisplayWhiteText(
          text: 'Add New Task',
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Task Title',
                  style: context.textTheme.titleLarge,
                ),
                const Gap(10),
                TextField(
                  readOnly: false,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  autocorrect: false,
                  controller: _titleController,
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
                  maxLines: null,
                ),
              ],
            ),
            const Gap(30),
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  Text(
                    'Category',
                    style: context.textTheme.titleLarge,
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
            const Gap(30),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Date',
                        style: context.textTheme.titleLarge,
                      ),
                      const Gap(10),
                      TextField(
                        readOnly: true,
                        onTap: () => _selectDate(context, ref),
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
                          hintText: Helpers.dateFormatter(ref.watch(
                              dateProvider)),
                          suffixIcon: IconButton(
                            onPressed: () => _selectDate(context, ref),
                            icon: const Icon(Icons.calendar_month),
                          ),
                        ),
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Time',
                        style: context.textTheme.titleLarge,
                      ),
                      const Gap(10),
                      TextField(
                        readOnly: true,
                        onTap: () => _selectTime(context, ref),
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
                          hintText: Helpers.timeToString(ref.watch(
                              timeProvider)),
                          suffixIcon: IconButton(
                            onPressed: () => _selectTime(context, ref),
                            icon: const Icon(Icons.access_time),
                          ),
                        ),
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Task Description',
                  style: context.textTheme.titleLarge,
                ),
                const Gap(10),
                TextField(
                  readOnly: false,
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  autocorrect: false,
                  controller: _descController,
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
                    hintText: 'Task Description',
                    suffixIcon: null,
                  ),
                  maxLines: 6,
                ),
              ],
            ),
            const Gap(30),
             ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple.shade300),
                ),
                onPressed: () {
                  _createTask(context, ref);
                  Navigator.pop(context);
                },

                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: DisplayWhiteText(
                    text: 'Save',
                  ),
                ),
            ),
            const Gap(30),
          ],

        ),
      ),
    );
  }

  void _createTask(BuildContext context, WidgetRef ref) async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final date = ref.watch(dateProvider);
    final time = ref.watch(timeProvider);
    final category = ref.watch(categoryProvider) ?? TaskCategory.others;
    final user = FirebaseAuth.instance.currentUser;
    if (title.isNotEmpty && description.isNotEmpty) {
    final task = Task(
      id: '',
      taskTitle: title,
      taskDesc: description,
      userId: user?.uid ?? '',
      category: category,
      priority: TaskPriority.Low,
      date: DateTime(date.year, date.month, date.day, time.hour, time.minute),
      isCompleted: false,
    );
    print('${task.taskTitle} ${task.category.toString()}');
    await ref.read(taskCRUDProvider).addTask(context, task);


    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task created successfully',
            style: context.textTheme.bodyMedium,
          ),
          backgroundColor: context.colorScheme.onSecondary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: context.textTheme.bodyMedium,
          ),
          backgroundColor: context.colorScheme.onSecondary,
        ),
      );
    }
  }

  void _selectDate(BuildContext context, WidgetRef ref) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime
          .now()
          .year + 5),
    );
    if (pickedDate != null) {
      ref
          .read(dateProvider.notifier)
          .state = pickedDate;
    }
  }

  void _selectTime(BuildContext context, WidgetRef ref) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      ref
          .read(timeProvider.notifier)
          .state = pickedTime;
    }
  }
}