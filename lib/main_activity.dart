import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'CRUDOperations.dart';
import 'login.dart';
import 'todolist.dart';
final taskCRUDProvider = Provider<TaskCRUD>((ref) => TaskCRUD(ref));
class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
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
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
              appBar: AppBar(
                title: Text('My Todo List'),
                actions: [
                  ElevatedButton(
                      onPressed: signOut,
                      child: Text('logout'),
                  ),
                ],
              ),
              body: TodoListPage(),

          );
          }
      },
    );
  }
}
