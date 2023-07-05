import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:holdit/utilities/generics/get_arguments.dart';

import '../../services/auth/auth_service.dart';
import '../../services/cloud/cloud_todo.dart';
import '../../services/cloud/firebase_cloud_storage.dart';

class CreateUpdateTodoView extends StatefulWidget {
  const CreateUpdateTodoView({super.key});

  @override
  State<CreateUpdateTodoView> createState() => _CreateUpdateTodoViewState();
}

class _CreateUpdateTodoViewState extends State<CreateUpdateTodoView> {
  CloudTodo? _todo;
  late final FirebaseCloudStorage _todoService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _todoService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  Future<CloudTodo> createOrGetExistingTodo(BuildContext context) async {
    final widgetTodo = context.getArgument<CloudTodo>();

    if (widgetTodo != null) {
      _todo = widgetTodo;

      _textController.text = widgetTodo.text;
      return widgetTodo;
    }
    final existingTodo = _todo;
    if (existingTodo != null) {
      return existingTodo;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newTodo = await _todoService.createNewTodo(ownerUserId: userId);
    _todo = newTodo;
    return newTodo;
  }

  void _textControllerListener() async {
    final todo = _todo;
    if (todo == null) {
      return;
    }
    final text = _textController.text;
    await _todoService.updateTodo(
      documentId: todo.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _deleteTodoIfTextIsEmpty() {
    final todo = _todo;
    if (_textController.text.isEmpty && todo != null) {
      _todoService.deleteTodo(documentId: todo.documentId);
    }
  }

  void _saveTodoIfTextNotEmpty() async {
    final todo = _todo;
    final text = _textController.text;
    if (todo != null && text.isNotEmpty) {
      await _todoService.updateTodo(
        documentId: todo.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteTodoIfTextIsEmpty();
    _saveTodoIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDF4F5),
      appBar: AppBar(
        leading: const Icon(
          Icons.note_add,
          color: Colors.deepPurple,
          size: 35,
        ),
        toolbarHeight: 100,
        title: const Text(
          'New Task',
          style: TextStyle(
              fontSize: 30,
              color: Colors.black,
              fontFamily: 'MainFont',
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.save,
                color: Colors.black,
              ))
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingTodo(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _todo = snapshot.data;
              _setupTextControllerListener();
              return SingleChildScrollView(
                child: Column(children: [
                  NoteViewTextFieldItem(textController: _textController),
                ]),
              );

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class NoteViewTextFieldItem extends StatelessWidget {
  const NoteViewTextFieldItem({
    super.key,
    required TextEditingController textController,
  }) : _textController = textController;

  final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _textController,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: GoogleFonts.outfit(fontSize: 22),
        decoration: const InputDecoration(
            hintText: 'Start typing your note...',
            hintStyle: TextStyle(fontFamily: 'MainFont', fontSize: 20),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffFDF4F5))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffFDF4F5)))),
      ),
    );
  }
}
