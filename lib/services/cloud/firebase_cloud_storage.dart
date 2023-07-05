import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holdit/services/cloud/cloud_note.dart';
import 'package:holdit/services/cloud/cloud_storage_constants.dart';
import 'package:holdit/services/cloud/cloud_storage_exceptions.dart';
import 'package:holdit/services/cloud/cloud_todo.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseCloudStorage {
  final storage = FirebaseStorage.instance;
  final picker = ImagePicker();
  final notes = FirebaseFirestore.instance.collection('notes');
  final todos = FirebaseFirestore.instance.collection('todos');
  String imageUrl = '';

  //cloud note features
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<String> pickAnImageAndGetUrl() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images');
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);

      try {
        await referenceImageToUpload.putFile(File(file.path));

        imageUrl = await referenceImageToUpload.getDownloadURL();
        return imageUrl;
      } catch (error) {
        throw Exception();
      }
    } else {
      return '';
    }
  }

  Future<void> addImageToNote({
    required String documentId,
    required String imageUrl,
  }) async {
    try {
      await notes.doc(documentId).update({imageUrlFieldName: imageUrl});
    } catch (e) {
      throw CouldNotAddImageToNoteException();
    }
  }

  Future<void> deleteImageInTheNote({
    required String documentId,
    required String imageUrl,
  }) async {
    try {
      final imageRef = storage.refFromURL(imageUrl);

      await notes.doc(documentId).update({imageUrlFieldName: null});
      await imageRef.delete();
    } catch (e) {
      throw CouldNotDeletImageException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notes.snapshots().map((event) => event.docs
        .map((doc) => CloudNote.fromSnapshot(doc))
        .where((note) => note.ownerUserId == ownerUserId));
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudNote.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });

    final fetchedNote = await document.get();

    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  //cloud todo features
  Future<CloudTodo> createNewTodo({required String ownerUserId}) async {
    final document = await todos.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });

    final fetchedTodo = await document.get();
    return CloudTodo(
      documentId: fetchedTodo.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  Future<void> deleteTodo({required String documentId}) async {
    try {
      await todos.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteTodoException();
    }
  }

  Future<void> updateTodo({
    required String documentId,
    required String text,
  }) async {
    try {
      await todos.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateTodoException();
    }
  }

  Stream<Iterable<CloudTodo>> allTodos({required String ownerUserId}) {
    return todos.snapshots().map((event) => event.docs
        .map((doc) => CloudTodo.fromSnapshot(doc))
        .where((todo) => todo.ownerUserId == ownerUserId));
  }

  Future<Iterable<CloudTodo>> getTodos({required String ownerUserId}) async {
    try {
      return await todos
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudTodo.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllTodosException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
