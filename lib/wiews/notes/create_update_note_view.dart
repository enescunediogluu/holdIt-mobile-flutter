import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:holdit/services/auth/auth_service.dart';
import 'package:holdit/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:holdit/utilities/generics/get_arguments.dart';
import 'package:holdit/services/cloud/cloud_note.dart';
import 'package:holdit/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  CloudNote? _note;
  late final FirebaseCloudStorage _noteService;
  late final TextEditingController _textController;

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;

      _textController.text = widgetNote.text;
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _noteService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _noteService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _noteService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _noteService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  void _initImagePath() async {
    final note = _note;
    final imagePath = await _noteService.pickAnImageAndGetUrl();
    if (note != null) {
      _noteService.addImageToNote(
          documentId: note.documentId, imageUrl: imagePath);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.image),
        onPressed: () async {
          _initImagePath();
        },
      ),
      backgroundColor: const Color(0xffFDF4F5),
      appBar: AppBar(
        leading: const Icon(
          Icons.note_add,
          color: Colors.deepPurple,
          size: 35,
        ),
        toolbarHeight: 100,
        title: const Text(
          'New Note',
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
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(
              Icons.share,
              color: Colors.black,
            ),
          ),
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
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data;
              _setupTextControllerListener();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: GoogleFonts.outfit(fontSize: 22),
                      decoration: const InputDecoration(
                          hintText: 'Start typing your note...',
                          hintStyle:
                              TextStyle(fontFamily: 'MainFont', fontSize: 20),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffFDF4F5))),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xffFDF4F5)))),
                    ),
                  ),
                ],
              );

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
