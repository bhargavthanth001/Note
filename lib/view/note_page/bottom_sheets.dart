import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/model/folder_model.dart';
import 'package:notes/model/note_model.dart';
import 'package:notes/view/login_area/login_page.dart';

import '../../model/label_model.dart';

class DisplayBottmSheet {
  static Color hecToColor(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static void showLabel(BuildContext context, String noteId) {
    Stream<List<LabelModel>> getLabel() {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('label')
          .snapshots()
          .map((event) => event.docs
              .map((doc) => LabelModel.fromJson(doc.data()))
              .toList());
    }

    Widget Label(LabelModel labelModel) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Card(
                child: ListTile(
                    leading:
                        const Icon(Icons.label_outlined, color: Colors.black),
                    title: Text(
                      labelModel.title!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      DocumentReference documentReference = FirebaseFirestore
                          .instance
                          .collection('users')
                          .doc(currentUser!.uid)
                          .collection('notes')
                          .doc(noteId);
                      FirebaseFirestore.instance
                          .runTransaction((transaction) async {
                        await transaction.update(documentReference, {
                          'labelName': labelModel.title,
                          'color': labelModel.color
                        });
                        Navigator.pop(context);
                      });
                    }),
                color: hecToColor(labelModel.color!)),
          ),
        ],
      );
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: StreamBuilder<List<LabelModel>>(
              stream: getLabel(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Somthing went wrong !!!",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final result = snapshot.data!;
                  return ListView(children: result.map((Label)).toList());
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          );
        });
  }

  static void showFolder(BuildContext context, String? noteId,
      String? noteTitle, String? noteDescription) {
    Stream<List<FolderModel>> getFolder() {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('folders')
          .snapshots()
          .map((event) => event.docs
              .map((doc) => FolderModel.fromJson(doc.data()))
              .toList());
    }

    Widget Folder(FolderModel folderModel) {
      return Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Card(
          child: ListTile(
            leading: const Icon(
              Icons.folder,
              color: Colors.lightBlue,
              size: 40,
            ),
            title: Text(
              folderModel.title!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .collection('notes')
                  .doc(noteId)
                  .delete();

              FolderNoteDataHandler.addFolderNote(
                  folderModel.id, noteId, noteTitle, noteDescription);
              Navigator.pop(context);
            },
          ),
        ),
      );
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: StreamBuilder<List<FolderModel>>(
              stream: getFolder(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Somthing went wrong !!!",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final result = snapshot.data!;
                  return ListView(children: result.map((Folder)).toList());
                } else {
                  return Center(
                    child: Icon(
                      Icons.error_outlined,
                      size: 100,
                    ),
                  );
                }
              },
            ),
          );
        });
  }
}
