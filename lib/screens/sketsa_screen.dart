import 'package:flutter/material.dart';

class SketsaScreen extends StatelessWidget {
  const SketsaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sketsa Screen')),
      body: const Center(child: Text('Sketsa Screen (Boilerplate)')),
    );
  }
}
