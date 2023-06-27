import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:notes/model/label_model.dart';
import '../login_area/login_page.dart';
import '../note_page/HomePage.dart';

class LabelMaker extends StatefulWidget {
  const LabelMaker({Key? key}) : super(key: key);

  @override
  State<LabelMaker> createState() => _LabelMakerState();
}

class _LabelMakerState extends State<LabelMaker> {
  TextEditingController labelName = TextEditingController();
  Color color = Colors.white;
  String colorDemo = "#6aa84f";

  Stream<List<LabelModel>> getData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('label')
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => LabelModel.fromJson(doc.data())).toList());
  }

  Widget Label(LabelModel labelModel) {
    return Card(
        child: ListTile(
          leading: const Icon(Icons.label_outlined, color: Colors.black),
          title: Text(
            labelModel.title!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    labelName.text = labelModel.title!;
                    return showLabelDialog(labelModel.id, labelName.text);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black),
                  onPressed: () {
                    return deleteDialog(
                        labelModel.id!, labelModel.title!, labelModel);
                  },
                ),
              ],
            ),
          ),
        ),
        color: hecToColor(labelModel.color!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Label"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => HomePage()),
                (Route<dynamic> route) => false);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder<List<LabelModel>>(
            stream: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint("Error >> ${snapshot.toString()}");
                return Center(
                  child: Text(snapshot.toString()),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final result = snapshot.data!;
                return ListView(
                  children: result.map((Label)).toList(),
                );
              } else {
                return Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.label_off_outlined,
                      color: Colors.grey,
                      size: 80,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "No Label",
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
        child: const Icon(Icons.add),
        onPressed: () {
          return showLabelDialog(null, null);
        },
      ),
    );
  }

  //method to show the title in alert dialog in create label
  String Title(String? id) {
    if (id == null) {
      return "Add new label";
    } else
      return "Edit label";
  }

  //method for the create or update the label
  void showLabelDialog(String? id, String? _title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Title(id)),
            content: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: TextFormField(
                    controller: labelName,
                    decoration: InputDecoration(
                      hintText: _title == "" ? "Enter the name" : "",
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: BlockPicker(
                    pickerColor: color,
                    availableColors: const [
                      Colors.grey,
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.blue,
                      Colors.purpleAccent,
                      Colors.cyanAccent
                    ],
                    onColorChanged: (color) =>
                        setState(() => this.color = color),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('cancel')),
              TextButton(
                  onPressed: () {
                    String title = labelName.text;
                    String colors = '#${color.value.toRadixString(16)}';
                    debugPrint("Color is -> $colors");
                    final coloris =
                        Color(int.parse(colors.substring(1, 7), radix: 16));

                    print("color is >>>>>>>>>  $coloris");
                    if (id != null) {
                      if (title.isNotEmpty) {
                        final labelModel =
                            LabelModel(id: id, title: title, color: colors);

                        LabelDataHandler.updateLabel(labelModel);
                      }
                    }
                    if (id == null && title.isNotEmpty) {
                      final labelModel =
                          LabelModel(title: title, color: colors);

                      LabelDataHandler.addLabel(labelModel);
                    }
                    labelName.text = "";
                    Navigator.pop(context, 'Ok');
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }

  //method to delete the label
  void deleteDialog(String? id, String title, LabelModel labelModel) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete label ?"),
            content: Text('Do you want to delete $title ?'),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('cancel')),
              TextButton(
                  onPressed: () {
                    LabelDataHandler.deleteLabel(labelModel);

                    Navigator.pop(context, 'Ok');
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }

  Color hecToColor(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}
