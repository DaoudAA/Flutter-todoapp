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
      appBar: AppBar(
        title: Text('${t.taskTitle}' ,
          style: TextStyle(fontSize: 24.0),
        ),
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
                style: TextStyle(fontSize: 22.0, color: Colors.black),
              ),
            ],
          )
      ),
    );
  }
}
