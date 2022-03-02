import 'package:flutter/material.dart';
import 'timer.dart';

void main() {
  runApp(Rapidtimer());
}

class Rapidtimer extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessTimer',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: TimerPage(title: 'ChessTimer'),
    );
  }
}
