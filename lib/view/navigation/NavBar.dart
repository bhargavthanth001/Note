import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/model/user_model.dart';
import 'package:notes/view/note_page/HomePage.dart';
import 'package:notes/view/folder_page/folder_make.dart';
import 'package:notes/view/label_page/label_maker.dart';
import 'package:notes/view/note_portfolio/portfolio.dart';

import '../login_area/login_page.dart';

class ShowSideNavigation extends StatefulWidget {
  const ShowSideNavigation({
    Key? key,
  }) : super(key: key);

  @override
  State<ShowSideNavigation> createState() => _ShowSideNavigationState();
}

class _ShowSideNavigationState extends State<ShowSideNavigation> {
  var userdata;
  String? username;
  String? email;

  Future<UserModel> getData() async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (data.exists) {
      return UserModel.fromJson(data.data() as Map<String, dynamic>);
    } else {
      throw Exception('user not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<UserModel>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserModel user = snapshot.data!;
                  return UserAccountsDrawerHeader(
                      accountName: Text(
                        // "${widget.username}",
                        user.username!,
                        style: TextStyle(fontSize: 20),
                      ),
                      accountEmail:
                          // Text("${widget.email}"),
                          Text(user.email!),
                      currentAccountPicture: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: Container(
                            height: 25,
                            width: 25,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                                border: Border.all(
                                    color: Colors.white, width: 0.5)),
                            // padding: EdgeInsets.all(8.0),
                            child: Text(
                              user.username!.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )));
                } else {
                  debugPrint("Data >> $snapshot");
                  return UserAccountsDrawerHeader(
                    accountEmail: CircularProgressIndicator(),
                    accountName: CircularProgressIndicator(),
                  );
                }
              }),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text("Folder"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateFloder())),
          ),
          ListTile(
            leading: const Icon(Icons.sticky_note_2_outlined),
            title: const Text("Notes"),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage())),
          ),
          ListTile(
              leading: const Icon(Icons.label_outlined),
              title: const Text("Labels"),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => LabelMaker()))),
          const Divider(),
          FutureBuilder<UserModel>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserModel user = snapshot.data!;
                  return ListTile(
                      leading: const Icon(
                        Icons.account_circle_sharp,
                      ),
                      title: const Text("Profile"),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => NotePortfolio(
                                    userId: user.userId!,
                                    username: user.username!,
                                    email: user.email!,
                                  ))));
                } else {
                  return ListTile(
                    leading: const Icon(
                      Icons.account_circle_sharp,
                    ),
                    title: const Text("Profile"),
                  );
                }
              }),
          ListTile(
            leading: const Icon(Icons.exit_to_app_sharp),
            title: const Text("Exit"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
