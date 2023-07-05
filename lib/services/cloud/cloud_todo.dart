import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holdit/services/cloud/cloud_storage_constants.dart';

class CloudTodo {
  final String documentId;
  final String ownerUserId;
  final String text;
  bool? isTaskCompleted;

  CloudTodo({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    this.isTaskCompleted = false,
  });

  CloudTodo.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String,
        isTaskCompleted = snapshot.data()[isCompletedFieldName];
}
