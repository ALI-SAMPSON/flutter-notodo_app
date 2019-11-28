import 'package:flutter/material.dart';
import 'package:notodo_app/ui/notodo_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text("Todo list App"),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),

      body: new NoToDoScreen(),

    );
  }
}
