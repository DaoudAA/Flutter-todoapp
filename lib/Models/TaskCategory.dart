import 'package:flutter/material.dart';

enum TaskCategory {
  education(Icons.school, Colors.blueGrey),
  health(Icons.favorite, Colors.orange),
  home(Icons.home, Colors.green),
  personal(Icons.person, Colors.lightBlue),
  shopping(Icons.shopping_bag, Colors.deepOrange),
  work(Icons.work, Colors.amber),
  others(Icons.calendar_month_rounded, Colors.purple);



  final IconData icon;
  final Color color;
  const TaskCategory(this.icon, this.color);
}