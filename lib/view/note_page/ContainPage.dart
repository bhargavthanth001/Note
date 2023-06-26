import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/model/note_model.dart';
import 'package:notes/model/user_model.dart';
import 'package:notes/view/login_area/register_page.dart';

import '../login_area/login_page.dart';

class Content extends StatefulWidget {
  final String? n_id;
  final String? n_title;
  final String? n_description;

  const Content({Key? key, this.n_id, this.n_title, this.n_description})
      : super(key: key);

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  bool _isUpdate = false;

  var _MyFormKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> dataIs = [];

  Future<DataNote?> readData() async {
    final docUser = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notes')
        .doc(widget.n_id);
    final snapshot = await docUser.get();

    if (snapshot.exists) {
      return DataNote.fromJson(snapshot.data()!);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
  }

  Widget Note(DataNote dataNote) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 20, left: 10),
            child: ListTile(
              title: Text(
                "Title",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(dataNote.title!),
            )),
        Container(
            margin: EdgeInsets.only(top: 20, left: 10),
            child: ListTile(
              title: Text(
                "Description",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(dataNote.description!),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context, _isUpdate)),
        title: Text(widget.n_id == null ? "Create Note " : "Edit Note "),
      ),
      body: SafeArea(
        child: Container(
          child: Builder(builder: (context) {
            if (widget.n_id != null &&
                widget.n_title == null &&
                widget.n_description == null)
              return FutureBuilder<DataNote?>(
                  future: readData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final user = snapshot.data;

                      return user == null
                          ? Center(child: Text("No user "))
                          : Note(user);
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  });
            else if (widget.n_title == null && widget.n_description == null) {
              return note(null, null, null);
            } else {
              return note(widget.n_title!, widget.n_description!, widget.n_id);
            }
          }),
        ),
      ),
    );
  }

  Widget note(String? _title, String? _description, String? noteId) {
    if (_title != null && _description != null) {
      title.text = _title;
      description.text = _description;
    }
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
                  hintText: widget.n_title == null ? "Enter the title" : ""),
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
                hintText: widget.n_description == null
                    ? "Enter the title"
                    : widget.n_description,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                bool valid = _MyFormKey.currentState!.validate();

                String _title = title.text;
                String _description = description.text;

                if (valid) {
                  print("valid.....");
                  print("note null");
                  final uid = currentUser!.uid;

                  if (noteId == null) {
                    final dataNotes =
                        DataNote(title: _title, description: _description);
                    NoteDataHandler.addNotes(dataNotes, uid);
                  } else {
                    final dataNotes = DataNote(
                        id: noteId, title: _title, description: _description);
                    NoteDataHandler.updateNotes(dataNotes);
                  }

                  _isUpdate = true;
                  Navigator.pop(context, _isUpdate);
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
  }
}
