import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/view/login_area/register_page.dart';
import 'package:notes/view/note_page/HomePage.dart';

User? currentUser = FirebaseAuth.instance.currentUser;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  var _myFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Login to your account",
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Container(
                child: Form(
                  key: _myFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: email,
                        validator: (_email) {
                          if (_email!.isEmpty) {
                            return "Enter the email";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            hintText: "Enter the email"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: password,
                        obscureText: true,
                        validator: (_password) {
                          if (_password!.isEmpty) {
                            return "Enter the password";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            hintText: "Enter the password"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      MaterialButton(
                        height: 60,
                        minWidth: double.infinity,
                        onPressed: () async {
                          String _email = email.text;
                          String _password = password.text;
                          User? user;
                          bool? valid = _myFormKey.currentState!.validate();

                          if (valid) {
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                      email: _email, password: _password);
                              print("user id is >>>> ${currentUser!.uid}");

                              currentUser = userCredential.user;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => HomePage()));
                            } on FirebaseAuthException catch (e) {
                              if (e.code == "user-not-found") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('user not found')));
                              } else if (e.code == "wrong-password") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('wrong password')));
                              }
                            }
                          } else {
                            _myFormKey.currentState!.validate();
                          }
                        },
                        child: Text(
                          "Login",
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Don't have an account?"),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => RegisterPage()));
                      },
                      child: Text("Sign up"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
