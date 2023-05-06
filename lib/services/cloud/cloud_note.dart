import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_flutter_app/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/material.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String title;
  final String text;

  const CloudNote(
      {required this.documentId,
      required this.ownerUserId,
      required this.title,
      required this.text});

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        title = snapshot.data()[titleFieldName],
        text = snapshot.data()[textFieldName];
}
