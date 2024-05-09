import 'package:flutter/material.dart';
import 'package:knowact/pages/chatbot.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MaterialApp(
      title: "Awesome app",
      home: ChatScreen(),
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      // routes: {"/home": (context) => HomePage()},
    ),
  );
}
