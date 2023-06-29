import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../view/login_area/login_page.dart';
import '../view/note_page/home_page.dart';

class AuthenticationServices {
  static void createUser(String _username, String _email, String _password) {
    final userModel =
        UserModel(username: _username, email: _email, password: _password);
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password)
        .then((value) => {
              debugPrint("user created"),
              UserData.addUser(userModel, currentUser!.uid)
            });
  }

  static void signIn(
      String _email, String _password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      print("user id is >>>> ${currentUser!.uid}");

      currentUser = userCredential.user;
      Navigator.push(
          context, MaterialPageRoute(builder: (builder) => HomePage()));
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == "invalid-email") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('user not found')));
      } else if (e.code == "wrong-password") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('wrong password')));
      }
    }
  }

  static void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
