import 'package:flutter/material.dart';
import 'package:gdg_2022/views/home_page.dart';

void main() {
  runApp(const GdgApp());
}

class GdgApp extends StatelessWidget {
  const GdgApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GDG 2022',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(
        name: 'Nilton',
      ),
    );
  }
}
