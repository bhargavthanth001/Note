import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notes/services/authenticate_services.dart';
import 'package:notes/view/login_area/login_page.dart';

import '../../controller/responsive_size.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController c_password = TextEditingController();
  var _myFormKey = GlobalKey<FormState>();
  bool isUserName = false;
  bool isEmail = false;

  List<Map<String, dynamic>> users = [];

  RegExp password_validation =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  RegExp email_validation = RegExp("^[a-z0-9+_.-]+@gmail.com");

  bool _validatePassword(String password) {
    String _password = password.trim();

    if (password_validation.hasMatch(_password)) {
      return true;
    } else {
      return false;
    }
  }

  bool _validateEmailRegEx(String email) {
    String _email = email.trim();
    if (email_validation.hasMatch(_email)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = ResponsiveSize.screenHeight(context);

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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
          child: Column(
            children: [
              Column(
                children: [
                  Text(
                    "Sign up",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Create an account it's free",
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Form(
                  key: _myFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Username", style: TextStyle(fontSize: 15)),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: username,
                        validator: (_username) {
                          if (_username!.isEmpty) {
                            return "Enter the username";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Email", style: TextStyle(fontSize: 15)),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: email,
                        validator: (_email) {
                          if (_email!.isEmpty) {
                            return "Enter the email";
                          } else {
                            if (_validateEmailRegEx(_email)) {
                              return null;
                            } else {
                              return "Enter the valid email";
                            }
                          }
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("Password", style: TextStyle(fontSize: 15)),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: password,
                        obscureText: true,
                        validator: (password) {
                          if (password!.isEmpty) {
                            return "Enter the password";
                          } else {
                            if (_validatePassword(password)) {
                              return null;
                            } else {
                              return "Password contain atleast 8 charachter \n"
                                  "1 capital letter \n"
                                  "1 small letter \n"
                                  "1 number \n"
                                  "1 special character";
                            }
                          }
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("C_Password", style: TextStyle(fontSize: 15)),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        controller: c_password,
                        obscureText: true,
                        validator: (c_password) {
                          if (c_password!.isEmpty) {
                            return "Enter the confirm password";
                          } else {
                            if (password.text == c_password) {
                              return null;
                            } else {
                              return "password and confirm password must be same";
                            }
                          }
                        },
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: MaterialButton(
                  height: screenHeight / 13.3,
                  minWidth: double.infinity,
                  onPressed: () {
                    bool? valid = _myFormKey.currentState!.validate();
                    if (valid) {
                      String _username = username.text;
                      String _email = email.text;
                      String _password = password.text;
                      AuthenticationServices.createUser(
                          _username, _email, _password);
                      Fluttertoast.showToast(msg: "Register successfully");
                      Navigator.pop(context);
                    } else {
                      _myFormKey.currentState!.validate();
                    }
                  },
                  child: Text("Sign up"),
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Already have an account?"),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => LoginScreen()));
                      },
                      child: Text("Login"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
