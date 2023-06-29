import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notes/view/navigation/nav_bar.dart';
import 'package:notes/view/note_page/contain_page.dart';
import 'package:notes/view/note_page/bottom_sheets.dart';
import 'package:notes/view/note_page/reminder.dart';
import '../../model/note_model.dart';
import '../../services/notification_helper.dart';
import '../login_area/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int notiId = 0;
  Stream<List<DataNote>> getData() {
    print("current id is:- ${currentUser!.uid}");
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notes')
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => DataNote.fromJson(doc.data())).toList());
  }

  Widget ReadNotes(DataNote dataNote) {
    return Card(
      elevation: 5,
      child: ListTile(
        title: Text(dataNote.title!),
        subtitle: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dataNote.description!),
            dataNote.labelName == null
                ? Container()
                : Card(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Text(dataNote.labelName!),
                    ),
                    color: DisplayBottmSheet.hecToColor(dataNote.color!),
                  )
          ],
        ),
        trailing: PopupMenuButton<int>(
          onSelected: (item) => onSelect(item, dataNote),
          itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                  value: 0,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit_outlined),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: const Text("Rename")),
                        ],
                      ),
                    ],
                  )),
              PopupMenuItem(
                  value: 1,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.delete_outline),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: const Text("Delete")),
                        ],
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.drive_folder_upload_outlined),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: const Text("Move to folder")),
                        ],
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 3,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.label_outline_rounded),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: dataNote.labelName == null
                                  ? Text("Add Label")
                                  : Text('Change label'))
                        ],
                      )
                    ],
                  )),
              PopupMenuItem(
                  value: 4,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.highlight_remove_sharp),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Text("Remove Label"))
                        ],
                      )
                    ],
                  )),
              PopupMenuItem<int>(
                  value: 5,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: dataNote.isReminder == true
                                  ? Text("Remove Reminder")
                                  : Text("Set Reminder")),
                        ],
                      ),
                    ],
                  )),
            ];
          },
        ),
        onTap: () {
          Navigator.of(context).push(_createRoute(dataNote.id));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ShowSideNavigation(),
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder<List<DataNote>>(
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
                return ListView(
                  children: notes.map((ReadNotes)).toList(),
                );
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
          bool value = await Navigator.of(context).push(
            _createRoute(null),
          );
          debugPrint("Value is return => $value");
          if (value) {
            getData();
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void deleteNote(DataNote dataNote) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete note ?"),
            content:
                Text('note "${dataNote.title}" will be removed from notes'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('cancel')),
              TextButton(
                  onPressed: () async {
                    if (dataNote.isReminder == true) {
                      await flutterLocalNotificationsPlugin.cancel(notiId);
                    }
                    Navigator.pop(context, 'Ok');
                    return NoteDataHandler.deleteNote(dataNote);
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }

  void deleteLabel(DataNote dataNote) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Remove Label ?"),
            content: dataNote.labelName == null
                ? Text('There is no label first add the label')
                : Text(
                    'Folder "${dataNote.labelName}" will be removed from this note'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('cancel')),
              TextButton(
                  onPressed: () {
                    DocumentReference documentReference = FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .collection('notes')
                        .doc(dataNote.id);
                    FirebaseFirestore.instance
                        .runTransaction((transaction) async {
                      await transaction.update(documentReference,
                          {'labelName': null, 'color': null});
                      Navigator.pop(context, 'Ok');
                    });
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }

  void _setReminder(
      int _id, String _noteId, String _title, String _description) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Set Reminder"),
            content: SetReminder(
              id: _id,
              noteId: _noteId,
              title: _title,
              description: _description,
            ),
          );
        });
  }

  Route _createRoute(String? n_id) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            Content(n_id: n_id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }

  void onSelect(item, DataNote dataNote) {
    switch (item) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => Content(
                    n_id: dataNote.id,
                    n_title: dataNote.title,
                    n_description: dataNote.description)));

        break;
      case 1:
        deleteNote(dataNote);
        break;
      case 2:
        DisplayBottmSheet.showFolder(
            context, dataNote.id!, dataNote.title, dataNote.description);
        break;
      case 3:
        DisplayBottmSheet.showLabel(context, dataNote.id!);
        break;
      case 4:
        deleteLabel(dataNote);
        break;
      case 5:
        dataNote.isReminder == true
            ? CencelReminder.cencelReminder(notiId, dataNote.id, context)
            : _setReminder(
                notiId, dataNote.id!, dataNote.title!, dataNote.description!);
        break;
    }
  }
}
