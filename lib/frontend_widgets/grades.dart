import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gvid_app2/webLoader.dart';
import 'package:gvid_app2/client.dart';
import 'package:gvid_app2/retrofit/restSchoolOnline.dart';
import 'package:preferences/preferences.dart';

final client = Client();
final filename = "grades.json";

class MarksWidget extends WebLoader<List<Mark>> {
  @override
  Future<List<Mark>> download() async {
    final hasLogged = await client.schoolOnline.login(
        PrefService.getString('sol_login'),
        PrefService.getString('sol_password')
    );
    if (!hasLogged) {
      return Future.error("Wrong password");
    }
    final marks = await client.schoolOnline.getMarksDetailed();
    saveToFile(filename, Mark.listToJson(marks));
    return marks;
  }

  @override
  Future<List<Mark>> load() async {
    final marks = await loadFromFile(filename);
    return (marks.isNotEmpty) ? Mark.listFromJson(marks) : download();
  }

  @override
  Widget success(List<Mark> marks) {
    return SingleChildScrollView(
      key: PageStorageKey('znamky'),
      child: Column(
        children: [
          Table(
            border: TableBorder(
                horizontalInside: BorderSide(width: 1, color: Colors.grey[800])
            ),
            columnWidths: {
              0: FlexColumnWidth(45),
              1: FlexColumnWidth(100),
              2: FlexColumnWidth(120),
              3: FlexColumnWidth(15)
            },
            children: [
              for(final mark in marks)
                createTableRow(mark),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget waiting() {
    return createLoadingCircle('Loading marks');
  }

  @override
  Widget failure() {
    return createErrorText('School Online Error');
  }
}

TableRow createTableRow(Mark gradeRow) {
  return TableRow(
    children: [
      Container(
        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 1),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            gradeRow.date.substring(0, gradeRow.date.length - 4),
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),

      Container(
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 1),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            gradeRow.subjectName,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),

      Container(
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 1),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            gradeRow.topic.substring(0, min(gradeRow.topic.length, 20)),
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),

      Container(
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 1),
        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            gradeRow.value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ],
  );
}