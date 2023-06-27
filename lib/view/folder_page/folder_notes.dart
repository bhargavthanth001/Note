import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:notes/view/login_area/login_page.dart';
import '../../model/folder_model.dart';

class FolderNote extends StatefulWidget {
  final String? folderId;
  const FolderNote({Key? key, this.folderId}) : super(key: key);

  @override
  State<FolderNote> createState() => _FolderNoteState();
}

class _FolderNoteState extends State<FolderNote> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  var _MyFormKey = GlobalKey<FormState>();
  int i = 0;

  Stream<List<Map<String, dynamic>>> getData() {
    CollectionReference collectionReference = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('folders');

    DocumentReference documentReference =
        collectionReference.doc(widget.folderId);

    return documentReference.snapshots().map((event) {
      List<Map<String, dynamic>> notes = [];
      if (event.exists) {
        Map<String, dynamic>? data = event.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('note')) {
          for (var note in data['note'] as List<dynamic>) {
            notes.add(Map<String, dynamic>.from(note));
          }
        }
      }
      return notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        actions: [
          // ChangeThemeButton()
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "somthing went wrong !!! ",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final notes = snapshot.data!;
                return Column(children: [
                  for (var note in notes)
                    Card(
                      elevation: 5,
                      child: ListTile(
                        title: Text(note['title']),
                        subtitle: Text(note['description']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    if (title.text != note['title'] &&
                                        description.text !=
                                            note['description']) {
                                      setState(() {});
                                    }

                                    title.text = note['title'];
                                    description.text = note['description'];
                                    showBottm(widget.folderId, note['id'],
                                        note['title'], note['description']);
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    deleteNote(widget.folderId!, note['id'],
                                        note['title'], note['description']);
                                  },
                                  icon: Icon(Icons.delete))
                            ],
                          ),
                        ),
                      ),
                    )
                ]);
              } else {
                return Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note_sharp,
                      color: Colors.grey,
                      size: 80,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "No Notes",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ));
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showBottm(null, null, null, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showBottm(
      String? folderId, String? uid, String? _title, String? _description) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Form(
            key: _MyFormKey,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: TextFormField(
                    controller: title,
                    validator: (title) {
                      if (title!.isEmpty) {
                        return "Enter the title";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: _title == null ? "Enter the name" : "",
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextFormField(
                    controller: description,
                    validator: (description) {
                      if (description!.isEmpty) {
                        return "Enter the description";
                      } else {
                        return null;
                      }
                    },
                    minLines: 4,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: _title == null ? "Description" : "",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      bool valid = _MyFormKey.currentState!.validate();

                      String noteTitle = title.text;
                      String noteDesc = description.text;

                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser!.uid)
                          .collection('folders')
                          .doc(widget.folderId)
                          .update({
                        'note': FieldValue.arrayRemove([
                          {
                            'id': uid,
                            'title': _title,
                            'description': _description
                          }
                        ])
                      });
                      if (valid) {
                        if (_title == null) {
                          uid = i.toString();

                          uid = (i++).toString();

                          FolderNoteDataHandler.addFolderNote(
                              widget.folderId, uid, noteTitle, noteDesc);

                          title.text = "";
                          description.text = "";
                          Navigator.pop(context);
                        } else {
                          FolderNoteDataHandler.updateFolderNote(
                              folderId!, uid, noteTitle, noteDesc);
                          title.text = "";
                          description.text = "";
                          Navigator.pop(context);
                        }
                      } else {
                        _MyFormKey.currentState!.validate();
                      }
                    },
                    child: const Text("save"),
                  ),
                )
              ],
            ),
          );
        });
  }

  void deleteNote(
      String? id, String? noteId, String? title, String? description) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete note ?"),
            content: Text('note "${title}" will be removed from notes'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Ok');
                    return FolderNoteDataHandler.deleteFolderNote(
                        widget.folderId!, noteId, title, description);
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }
}
