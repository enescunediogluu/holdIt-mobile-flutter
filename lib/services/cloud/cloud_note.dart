import 'package:cloud_firestore/cloud_firestore.dart';
import "cloud_storage_constants.dart";

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  String? imageUrl;

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    this.imageUrl,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String,
        imageUrl = snapshot.data()[imageUrlFieldName];
}
