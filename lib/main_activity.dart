import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist/AddEditScreen.dart';
import 'package:todolist/usefulwidgets/App_background.dart';
import 'package:todolist/utils/utils.dart';
import 'CRUDOperations.dart';
import 'login.dart';
import 'todolist.dart';
//final taskNotifier = TaskNotifier();
//final taskListRepository = TaskListRepository(taskNotifier );
//final taskCRUDProvidernew = Provider<TaskListRepository>((ref) => taskListRepository);
final taskCRUDProvider = Provider<TaskCRUD>((ref) => TaskCRUD(ref));
final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class MainActivity extends ConsumerWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSize = context.deviceSize;
    final date = ref.watch(dateProvider);

    Future<User?> initializeApp() async {
      final user = await _auth.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
      return user;
    }

    void signOut() async {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }

    initializeApp().then((user) {
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          AppBackground(
            headerHeight: deviceSize.height * 0.28,
            header: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => Helpers.selectDate(context, ref),
                    child: DisplayWhiteText(
                      text: Helpers.dateFormatter(date),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const DisplayWhiteText(text: 'My Todo List', size: 40),
                ],
              ),
            ),
          ),
          Positioned (
            top : 130,
            left :0 ,
            right : 0 ,
            child: TodoListPage(),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                signOut();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.logout),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
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
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () { Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTaskScreen(),
                ),
              );
              },
              tooltip: 'Add Task',
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
