import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:todolist/Models/TaskPriority.dart';
import 'package:todolist/usefulwidgets/widgets.dart';
import 'package:todolist/utils/utils.dart';

import 'Models/Task.dart';
import 'Models/TaskCategory.dart';

class CreateTaskScreen extends ConsumerWidget {
  final taskListProvider = StateProvider<List<DocumentSnapshot>>((ref) => []);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final categoryProvider = StateProvider.autoDispose<TaskCategory>((ref) {
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
    final colors = context.colorScheme.inverseSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade50,
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
                    hintText: 'Task Title',
                    suffixIcon: null,
                  ),
                  maxLines: null,
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
                    hintText: 'Task Description',
                    suffixIcon: null,
                  ),
                  maxLines: 6,
                ),
              ],
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
                            ref
                                .read(categoryProvider.notifier)
                                .state = category;
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: category.color.withOpacity(0.3),
                              border: Border.all(
                                width: 2,
                                color: category.color.withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                category.icon,
                                color: selectedCategory == category
                                    ? context.colorScheme.primary
                                    : category.color.withOpacity(0.5),
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
            ElevatedButton(
              onPressed: () => _createTask(context, ref),
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
    final category = ref.watch(categoryProvider).toString();
    final user = FirebaseAuth.instance.currentUser;

    if (title.isNotEmpty && description.isNotEmpty && user != null) {
      final newTaskDocument = await FirebaseFirestore.instance.collection('tasks').add({
        'taskTitle': title,
        'taskDesc': description,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day, time.hour, time.minute)),
        'category': category,
        'userId': user.uid,
      });

      final newTaskSnapshot = await newTaskDocument.get();

      ref.read(taskListProvider.notifier).state.add(newTaskSnapshot);

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