import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/notification_helper.dart';
import '../login_area/login_page.dart';

var items = ['Only Once', 'Daily', 'Monthly', 'Yearly'];

class SetReminder extends StatefulWidget {
  final int? id;
  final String? noteId;
  final String? title;
  final String? description;
  const SetReminder(
      {Key? key, this.id, this.noteId, this.title, this.description})
      : super(key: key);

  @override
  State<SetReminder> createState() => _SetReminderState();
}

class _SetReminderState extends State<SetReminder> {
  static String dropDownValue = items.first;
  static TextEditingController date = TextEditingController();
  static TextEditingController time = TextEditingController();

  void _datePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2024));

    if (pickedDate != null) {
      print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      print(
          formattedDate); //formatted date output using intl package =>  2021-03-16
      date.text = formattedDate; //set output date to TextField value.
    } else {}
  }

  void _timePicker() async {
    final TimeOfDay? newTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (newTime != null) {
      time.text = newTime.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 50),
                  child: const Text("reminder ? "),
                ),
                DropdownButton<String>(
                    value: dropDownValue,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: items.map((String items) {
                      return DropdownMenuItem(value: items, child: Text(items));
                    }).toList(),
                    onChanged: (String? newItem) {
                      setState(() {
                        dropDownValue = newItem!;
                      });
                    }),
              ],
            ),
            if (dropDownValue == "Only Once" ||
                dropDownValue == "Monthly" ||
                dropDownValue == "Yearly")
              Container(
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: TextFormField(
                  controller: date,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Enter the date",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: _datePicker,
                      )),
                ),
              ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: TextFormField(
                controller: time,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Enter the time",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.timer),
                      onPressed: _timePicker,
                    )),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: ElevatedButton(
                child: const Text("set reminder"),
                onPressed: () {
                  print("DropDown Value is : $dropDownValue");
                  List<String> dateStrings = date.text.split("-");
                  List<String> timeString = time.text.split(":");

                  int? _day;
                  int? _month;
                  int? _year;
                  int? _hour;
                  int? _minute;
                  var dateTime;

                  if (dropDownValue == "Only Once") {
                    _day = int.parse(dateStrings[0]);
                    _month = int.parse(dateStrings[1]);
                    _year = int.parse(dateStrings[2]);
                    _hour = int.parse(timeString[0]);
                    _minute = int.parse(timeString[1]);
                  }
                  if (dropDownValue == "Daily") {
                    _day = 0;
                    _month = 0;
                    _year = 0;
                    _hour = int.parse(timeString[0]);
                    _minute = int.parse(timeString[1]);
                  }
                  if (dropDownValue == "Monthly") {
                    _day = int.parse(dateStrings[0]);
                    _month = 0;
                    _year = int.parse(dateStrings[2]);
                    _hour = int.parse(timeString[0]);
                    _minute = int.parse(timeString[1]);
                  }
                  if (dropDownValue == "Yearly") {
                    _day = int.parse(dateStrings[0]);
                    _month = int.parse(dateStrings[1]);
                    _year = 0;
                    _hour = int.parse(timeString[0]);
                    _minute = int.parse(timeString[1]);
                  }

                  WidgetsFlutterBinding.ensureInitialized();
                  Noti.initialize();
                  dateTime = DateTime(_day!, _month!, _year!, _hour!, _minute!);
                  Noti().showNotification(
                      widget.id!, widget.title!, widget.description!, dateTime);
                  DocumentReference documentReference = FirebaseFirestore
                      .instance
                      .collection('users')
                      .doc(currentUser!.uid)
                      .collection('notes')
                      .doc(widget.noteId!);
                  FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    await transaction
                        .update(documentReference, {'isReminder': true});
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CencelReminder {
  static void cencelReminder(int id, String? noteId, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Cencel Reminder ? "),
            content: Text("Do you want to remove reminder from this note ?"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cencel")),
              TextButton(
                  onPressed: () async {
                    DocumentReference documentReference = FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .collection('notes')
                        .doc(noteId);
                    FirebaseFirestore.instance
                        .runTransaction((transaction) async {
                      await transaction
                          .update(documentReference, {'isReminder': false});
                    });
                    await flutterLocalNotificationsPlugin.cancel(id);
                    Navigator.pop(context);
                  },
                  child: Text("Ok"))
            ],
          );
        });
  }
}
