import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holdit/services/cloud/cloud_storage_constants.dart';

class CloudTodo {
  final String documentId;
  final String ownerUserId;
  final String text;
  bool isCompleted;

  CloudTodo({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    this.isCompleted = false,
  });

  CloudTodo.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String,
        isCompleted = snapshot.data()[isCompletedFieldName];
}
