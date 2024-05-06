import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todolist/Models/Task.dart';

class DetailScreen extends StatelessWidget {
  final Task task;
  const DetailScreen({Key? key,required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = task;
    return Scaffold(
        backgroundColor: Colors.deepPurple.shade50,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple.withOpacity(0.3),
          elevation: 0,
          centerTitle: true,
          title: Text('${t.taskTitle}' ,
            style: TextStyle(fontSize: 24.0, color: Colors.grey.shade900),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 16.0),
                Text(
                  t.taskDesc,
                  style: TextStyle(fontSize: 22.0, color: Colors.grey.shade900),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 4.0),
                    Text(
                      '${t.date.hour}:${t.date.minute}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(width: 16.0),
                    Icon(Icons.category),
                    SizedBox(width: 4.0),
                    Text(
                      '${t.category.name} category' , // Assuming category is a String
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            )
        ),
    );
  }
}
