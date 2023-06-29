import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/controller/responsive_size.dart';
import 'package:notes/services/authenticate_services.dart';
import 'package:notes/view/login_area/HomeUi.dart';
import 'package:notes/view/login_area/login_page.dart';

import '../note_page/HomePage.dart';

class NotePortfolio extends StatefulWidget {
  final String? userId;
  final String? username;
  final String? email;
  const NotePortfolio(
      {Key? key,
      required this.userId,
      required this.username,
      required this.email})
      : super(key: key);

  @override
  State<NotePortfolio> createState() => _NotePortfolioState();
}

class _NotePortfolioState extends State<NotePortfolio> {
  int _countNotes = 0;
  int _countFolders = 0;
  int _countLabels = 0;

  String get firstLetter => this.widget.username!.substring(0, 1).toUpperCase();

  void getData() async {
    AggregateQuerySnapshot notes = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('notes')
        .count()
        .get();

    AggregateQuerySnapshot folders = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('folders')
        .count()
        .get();

    AggregateQuerySnapshot labels = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('label')
        .count()
        .get();

    _countNotes = notes.count;
    _countFolders = folders.count;
    _countLabels = labels.count;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = ResponsiveSize.screenHeight(context);
    final double screenWidth = ResponsiveSize.screenWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (builder) => HomePage()),
              (route) => false),
        ),
      ),
      body: widget.userId == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned(
                  top: screenHeight / -20,
                  right: 0,
                  left: 0,
                  bottom: screenHeight * 0.63,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blue),
                    child: Center(
                      child: Column(
                        children: [
                          FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              child: Container(
                                margin: EdgeInsets.only(top: screenHeight / 16),
                                height: screenHeight / 10,
                                width: screenWidth / 2,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey,
                                    border: Border.all(
                                        color: Colors.white, width: 0.5)),
                                // padding: EdgeInsets.all(8.0),
                                child: Text(
                                  this.firstLetter,
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                          SizedBox(height: 10),
                          Container(
                            child: Text(widget.username!,
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Text(widget.email!,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight / 3.6,
                  left: 10,
                  right: 10,
                  bottom: 0,
                  child: ListView(
                    children: [
                      Container(
                        height: screenHeight / 6.2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: new LinearGradient(colors: [
                              Colors.greenAccent,
                              Colors.cyanAccent
                            ])),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Image.asset(
                                "assets/note.png",
                                height: 100,
                                width: 100,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 20),
                                child: ListTile(
                                  title: Text(
                                    "Notes",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  subtitle: Text("$_countNotes",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: screenHeight / 6.2,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: new LinearGradient(
                            colors: [
                              Colors.purpleAccent,
                              Colors.deepPurpleAccent
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Image.asset(
                                "assets/folder.png",
                                height: 100,
                                width: 100,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 20),
                                child: ListTile(
                                  title: Text(
                                    "Folders",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  subtitle: Text("$_countFolders",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: screenHeight / 6.2,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: new LinearGradient(
                                colors: [Colors.yellow, Colors.orange])),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Image.asset(
                                "assets/label.png",
                                height: 100,
                                width: 100,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 20),
                                child: ListTile(
                                  title: Text(
                                    "Labels",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                  subtitle: Text("$_countLabels",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      MaterialButton(
                        height: screenHeight / 16,
                        minWidth: double.infinity,
                        onPressed: () {
                          _signOut();
                        },
                        color: Colors.red,
                        child: Text("Sign out"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _signOut() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.error_outline_sharp,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 5,
                ),
                Text("log out")
              ],
            ),
            content: Text("Do you want to logout ?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("cancel")),
              TextButton(
                  onPressed: () {
                    AuthenticationServices.signOut();

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (builder) => Home()),
                        (Route<dynamic> route) => false);
                  },
                  child: Text("ok"))
            ],
          );
        });
  }
}
