import 'package:flutter/material.dart';
import 'package:notodo_app/ui/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // code to remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: new Home(),
    );
  }
}

