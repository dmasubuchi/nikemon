import 'package:flutter/material.dart';

void main() => runApp(const NikeApp());

class NikeApp extends StatelessWidget {
  const NikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Nike+ Clone App')),
      ),
    );
  }
}
