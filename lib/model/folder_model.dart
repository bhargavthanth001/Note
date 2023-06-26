import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:notes/view/login_area/login_page.dart';

class FolderModel {
  String? id;
  String? title;
  List<NoteElement>? note;

  FolderModel({
    this.id,
    this.title,
    this.note,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) => FolderModel(
        id: json["id"],
        title: json["title"],
        note: json["notes"] == null
            ? []
            : List<NoteElement>.from(
                json["notes"]!.map((x) => NoteElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "notes": note == null
            ? []
            : List<dynamic>.from(note!.map((x) => x.toJson())),
      };
}

class NoteElement {
  String? id;
  String? title;
  String? description;

  NoteElement({
    this.id,
    this.title,
    this.description,
  });

  factory NoteElement.fromJson(Map<String, dynamic> json) => NoteElement(
        id: json["id"],
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
      };
}

class FolderDataHandler {
  static Future addFolder(FolderModel folderModel) async {
    final addFolder = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('folders')
        .doc();
    folderModel.id = addFolder.id;
    final json = folderModel.toJson();
    await addFolder
        .set(json)
        .then((value) => debugPrint("folder added"))
        .catchError((onError) => debugPrint("Error !!! $onError"));
  }

  static void updateFolder(FolderModel folderModel) async {
    final updateFolder = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('folders')
        .doc();

    final result = folderModel.toJson();

    await updateFolder.update(result);
  }

  static void deleteFolder(FolderModel folderModel) async {
    final deleteFolder = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('folders')
        .doc();
    await deleteFolder.delete();
  }
}

class FolderNoteDataHandler {
  static Future addFolderNote(
      String? id, String? noteId, String? title, String? description) async {
    CollectionReference folderReference = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('folders');

    DocumentReference documentReference = folderReference.doc(id);

    documentReference.update({
      'note': FieldValue.arrayUnion([
        {'id': noteId, 'title': title, 'description': description}
      ])
    });
  }

  static void updateFolderNote(
      String id, String? noteId, String? title, String? description) async {
    CollectionReference folderReference = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('folders');

    DocumentReference documentReference = folderReference.doc(id);
    await documentReference.update({
      'note': FieldValue.arrayUnion([
        {'id': noteId, 'title': title, 'description': description}
      ])
    });
  }

  static void deleteFolderNote(
      String id, String? noteId, String? title, String? description) async {
    CollectionReference folderReference = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('folders');

    DocumentReference documentReference = folderReference.doc(id);
    documentReference.update({
      'note': FieldValue.arrayRemove([
        {'id': noteId, 'title': title, 'description': description}
      ])
    });
  }
}
