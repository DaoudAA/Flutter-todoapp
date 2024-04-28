import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolist/usefulwidgets/App_background.dart';
import 'package:todolist/utils/utils.dart';
import 'CRUDOperations.dart';
import 'login.dart';
import 'todolist.dart';
final taskCRUDProvider = Provider<TaskCRUD>((ref) => TaskCRUD(ref));
final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());
/*
class MainActivity extends ConsumerWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

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

  @override
  Widget build(BuildContext context,  WidgetRef ref) {
    final deviceSize = context.deviceSize;
    final date = ref.watch(dateProvider);
    return FutureBuilder<User?>(
      future: initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            body: Stack(
              children: [
              AppBackground(
              headerHeight: deviceSize.height * 0.3,
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
              body: TodoListPage(),
            ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      signOut();
                    },
                    child: const Text('Logout'),
                  ),
                ),
              ],
            )
          );
          }
      },
    );
  }
}
*/
class MainActivity extends ConsumerWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context,  WidgetRef ref) {
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
            headerHeight: deviceSize.height * 0.3,
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
            body: TodoListPage(),
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
        ],
      ),
    );
  }
}