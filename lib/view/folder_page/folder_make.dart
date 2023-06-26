import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/model/folder_model.dart';
import 'package:notes/view/folder_page/folder_notes.dart';
import 'package:notes/view/login_area/login_page.dart';

class CreateFloder extends StatefulWidget {
  const CreateFloder({Key? key}) : super(key: key);

  @override
  State<CreateFloder> createState() => _CreateFloderState();
}

class _CreateFloderState extends State<CreateFloder> {
  TextEditingController folderTitle = TextEditingController();

  Stream<List<FolderModel>> getData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('folders')
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => FolderModel.fromJson(doc.data())).toList());
  }

  Widget Folders(FolderModel folderModel) {
    return ListTile(
      leading: const Icon(
        Icons.folder,
        size: 40,
        color: Colors.lightBlue,
      ),
      title: Text(folderModel.title!),
      trailing: PopupMenuButton<int>(
        onSelected: (item) =>
            onSelect(folderModel.id!, item, folderModel.title!, folderModel),
        itemBuilder: (context) {
          return [
            PopupMenuItem<int>(
                value: 0,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit),
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
                        const Icon(Icons.delete),
                        Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text("Delete")),
                      ],
                    )
                  ],
                )),
          ];
        },
      ),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (builder) => FolderNote(
                  folderId: folderModel.id == null ? null : folderModel.id))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Folder"),
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder<List<FolderModel>>(
            stream: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint("Data is ==> $snapshot");
                return Center(
                  child: Text(
                    "somthing went wrong !!! ",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else if (snapshot.hasData) {
                final notes = snapshot.data!;
                return ListView(
                  children: notes.map((Folders)).toList(),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          return showMyDialog(null, null);
        },
      ),
    );
  }

  String Title(String? id) {
    if (id == null) {
      return "Create Folder";
    } else {
      return "Rename Folder";
    }
  }

  //method to create a new folder
  void showMyDialog(String? id, String? _title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Title(id)),
            content: Form(
              child: Container(
                child: TextFormField(
                  controller: folderTitle,
                  decoration: InputDecoration(
                    hintText: _title == null ? "Enter the name" : "",
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('cancel')),
              TextButton(
                  onPressed: () {
                    String title = folderTitle.text;

                    if (id == null) {
                      final folderModel = FolderModel(title: title);
                      FolderDataHandler.addFolder(folderModel);
                      folderTitle.text = "";
                    }
                    if (id != null) {
                      final folders = FolderModel(id: id, title: title);
                      FolderDataHandler.updateFolder(folders);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }

  //method for popmenu in scaffold
  void onSelect(String id, item, String title, FolderModel folderModel) {
    switch (item) {
      case 0:
        folderTitle.text = title;
        showMyDialog(id, folderTitle.text);
        break;

      case 1:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Delete Folder ?"),
                content: Text('Folder "$title" will be removed from notes'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('cancel')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'Ok');
                        return FolderDataHandler.deleteFolder(folderModel);
                      },
                      child: const Text('Ok'))
                ],
              );
            });
        break;
    }
  }
}
