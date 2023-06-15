import 'package:flutter/material.dart';

class NewNoteView extends StatelessWidget {
  const NewNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('New Note')),
        body: const Text('Write your new note here'));
  }
}
