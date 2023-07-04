import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:holdit/services/auth/auth_service.dart';
import 'package:holdit/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:holdit/utilities/dialogs/delete_image_dialog.dart';
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
  bool _imageDeleted = false;
  bool _isLoadingImage = false;
  bool _isUploadingImage = false;

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

  /*  void setDisplayFlag() {
    if (_isButtonUsed) {
      _displayFlag = '$_imageUrl';
    } else {
      _displayFlag = '${_note!.imageUrl}';
    }
  } */

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

  void _deleteImage() async {
    final note = _note;
    await _noteService.deleteImageInTheNote(
        documentId: _note!.documentId, imageUrl: _note!.imageUrl!);
    note!.imageUrl = null;
    setState(() {
      _imageDeleted = true;
    });
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
    setState(() {
      _isUploadingImage = true;
      // Set _isUploadingImage to true to prevent user interactions
    });

    final note = _note;
    final imagePath = await _noteService.pickAnImageAndGetUrl();
    if (note != null) {
      await _noteService.addImageToNote(
        documentId: note.documentId,
        imageUrl: imagePath,
      );
    }
    note!.imageUrl = imagePath;
    setState(() {
      _isUploadingImage = false;

      // Set _isUploadingImage to false to allow user interactions
    });
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
              return AbsorbPointer(
                absorbing: _isUploadingImage,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      NoteViewTextFieldItem(textController: _textController),
                      if (_isUploadingImage)
                        Container(
                          width: 350,
                          height: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[300],
                          ),
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                      if (_note!.imageUrl != null &&
                          !_imageDeleted &&
                          !_isLoadingImage)
                        GestureDetector(
                          onDoubleTap: () async {
                            final shouldDeleteImage =
                                await deleteImageDialog(context);
                            if (shouldDeleteImage) {
                              _deleteImage();
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              _note!.imageUrl!,
                              width: 350,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  _isLoadingImage = false;
                                  return child;
                                }
                                _isLoadingImage = true;
                                return Container(
                                  decoration:
                                      BoxDecoration(color: Colors.grey[300]),
                                  width: 350,
                                  height: 350,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 25,
                      )
                    ],
                  ),
                ),
              );

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// ignore: camel_case_types
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
