import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/view/login_area/login_page.dart';

class LabelModel {
  String? id;
  String? title;
  String? color;

  LabelModel({
    this.id,
    this.title,
    this.color,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) => LabelModel(
        id: json["id"],
        title: json["title"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "color": color,
      };
}

class LabelDataHandler {
  static Future addLabel(LabelModel labelModel) async {
    final labels = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('label')
        .doc();
    labelModel.id = labels.id;
    final json = labelModel.toJson();
    await labels.set(json);
  }

  static void updateLabel(LabelModel labelModel) async {
    final labels = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('label')
        .doc(labelModel.id);

    final result = labelModel.toJson();

    await labels.update(result);
  }

  static void deleteLabel(LabelModel labelModel) async {
    final labels = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('label')
        .doc(labelModel.id);
    await labels.delete();
  }
}
