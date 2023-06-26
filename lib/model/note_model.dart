import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/view/login_area/login_page.dart';

class DataNote {
  String? id;
  String? title;
  String? description;
  String? labelName;
  String? color;

  DataNote({
    this.id,
    this.title,
    this.description,
    this.labelName,
    this.color,
  });

  factory DataNote.fromJson(Map<String, dynamic> json) => DataNote(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        labelName: json["labelName"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "labelName": labelName,
        "color": color,
      };
}

class NoteDataHandler {
  static Future addNotes(DataNote dataNote, String? uid) async {
    final notes = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc();
    dataNote.id = notes.id;
    final json = dataNote.toJson();
    await notes.set(json);
  }

  static void updateNotes(DataNote dataNote) async {
    final notes = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notes')
        .doc(dataNote.id);

    final result = dataNote.toJson();

    await notes.update(result);
  }

  static void deleteNote(DataNote dataNote) async {
    final notes = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notes')
        .doc(dataNote.id);
    await notes.delete();
  }
}
