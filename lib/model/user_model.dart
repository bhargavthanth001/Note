// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? userId;
  String? username;
  String? email;
  String? password;

  UserModel({
    this.userId,
    this.username,
    this.email,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json["userId"],
        username: json["username"],
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "username": username,
        "email": email,
        "password": password,
      };
}

class UserData {
  static Future addUser(UserModel userModel, String? u_id) async {
    final user = FirebaseFirestore.instance.collection('users').doc(u_id);
    userModel.userId = user.id;
    final json = userModel.toJson();
    await user.set(json);
  }
}
