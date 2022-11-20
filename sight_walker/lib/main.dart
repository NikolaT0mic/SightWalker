import 'package:flutter/material.dart';

import 'views/home_page.dart';

void main() {
  runApp(const SightWalkerApp());
}

class SightWalkerApp extends StatelessWidget {
  const SightWalkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomePage(title: 'Sight Walker'),
    );
  }
}