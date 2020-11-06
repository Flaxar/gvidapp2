import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gvid_app2/client.dart';
import 'package:gvid_app2/retrofit/restSchoolOnline.dart';
import 'package:preferences/preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


final client = Client();

Future<List<List<Subject>>> loadScheduleFromWebAndSaveIt() async {
  final hasLogged = await client.schoolOnline.login(PrefService.getString('sol_login'), PrefService.getString('sol_password'));
  if (!hasLogged) {
    return Future.error("Login error");
  }
  final schedule = await client.schoolOnline.getCalendar();
  final directory = await getApplicationDocumentsDirectory();
  final calendarFile = await File("${directory.path}/calendar.json").create(recursive: true);
  final calendarJson = Subject.tableToJson(schedule);
  await calendarFile.writeAsString(calendarJson);
  return schedule;
}

Future<List<List<Subject>>> loadScheduleData() async {
  final directory = await getApplicationDocumentsDirectory();
  final calendarFile = await File("${directory.path}/calendar.json").create(recursive: true);
  final calendarSaved = await calendarFile.readAsString();
  if (calendarSaved.isEmpty) {
    return await loadScheduleFromWebAndSaveIt();
  }
  final calendarArray = Subject.tableFromJson(calendarSaved);
  return calendarArray;
}

Future<Widget> loadScheduleWidget() async {
  final data = await loadScheduleData();
  return Column(
    children: [
      Container(
        child: Center(
            child: Text(
                "Normalní rozvrh",
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.white
                )
            )
        ),
      ),
      createSchedule(trimSchedule(data)),
      Container(margin: EdgeInsets.all(5)),
      Container(
        child: Center(
            child: Text(
                "Korona rozvrh",
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.white
                )
            )
        ),
      ),
      createSchedule(trimSchedule(createCoronaSchedule(data)))
    ],
  );
}

List<List<Subject>> trimSchedule(List<List<Subject>> schedule) {
  var scheduleTrimmed = List<List<Subject>>();
  int globalMin = 10, globalMax = 0;

  for(final day in schedule) {
    globalMin = min(globalMin, day.indexWhere((element) => element != null));
    globalMax = max(globalMax, day.lastIndexWhere((element) => element != null));
  }

  for(final day in schedule) {
    if (globalMin != -1 && globalMax != -1) {
      scheduleTrimmed.add(day.sublist(globalMin, globalMax));
    } else {
      scheduleTrimmed.add([null, null, null, null, null, null, null]);
    }
  }

  return scheduleTrimmed;
}

List<List<Subject>> createCoronaSchedule(List<List<Subject>> schedule) {
  var meetHour = {'F': 2, 'B': 2, 'Ch': 2, 'M' : 3, 'NJ' : 3, 'FJ' : 3};
  final ignore = '217|218|311|IVT1|IVT2|IVT3';
  final counter = meetHour.map((key, value) => MapEntry(key, 0));
  final calendar = List<List<Subject>>.generate(5, (_) => List<Subject>(10));

  for (int i = 0; i < schedule.length; i++) {
    for (int j = 0; j < schedule[i].length; j++) {
      final subject = schedule[i][j];
      if (subject != null && !RegExp(ignore).hasMatch(subject.classroom)) {
        if (!meetHour.containsKey(subject.name)) {
          calendar[i][j] = subject;
          meetHour[subject.name] = 0;
          counter[subject.name] = 0;
        } else if (++counter[subject.name] == meetHour[subject.name]) {
          calendar[i][j] = subject;
        }
      }
    }
  }

  return calendar;
}

String parseClass(String classroom) {
  return classroom.split("-").first;
}

TableCell createScheduleCell(Subject subject, bool dvoj) {
  return TableCell(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
              right: !dvoj ? BorderSide(color: Colors.grey[600]) : BorderSide(color: Colors.transparent)
          ),
        ),
        padding: EdgeInsets.all(5),
        child: Column(
            children: [
              Text(
                subject?.name ?? "",
                style: TextStyle(
                    color: Colors.white
                ),
              ), //??????? - just Tom things
              Text(
                parseClass(subject?.classroom ?? "-"),
                style: TextStyle(
                    color: Colors.white
                ),
              )
            ]
        ),
      )
  );
}

TableRow createScheduleRow(List<Subject> schoolDay) {
  return TableRow(
      children: [
        for(int i = 0; i < schoolDay.length; i++)
          createScheduleCell(
              schoolDay[i],
              (
                  i < schoolDay.length - 1
                      && schoolDay[i] != null
                      && schoolDay[i]?.name == schoolDay[i + 1]?.name
              )
                  || i == schoolDay.length - 1
          ),
      ]
  );
}

Widget createSchedule(List<List<Subject>> schedule) {
  return Table(
    border: TableBorder(
      horizontalInside: BorderSide(width: 1, color: Colors.grey[600]),
      //verticalInside: BorderSide(width: 1, color: Colors.grey[600])
    ),
    children: [
      for(int i = 0; i < 5; i++)
        createScheduleRow(schedule[i]),
    ],
  );
}

RefreshController _refreshController = RefreshController(initialRefresh: false);

void _onRefresh() async{
  // monitor network fetch
  await Future.delayed(Duration(milliseconds: 1000));
  // if failed, use refreshFailed()
  _refreshController.refreshCompleted();
}

void _onLoading() async{
  // monitor network fetch
  await Future.delayed(Duration(milliseconds: 1000));
  // if failed,use loadFailed(),if no data return,use LoadNodata()
  //items.add((items.length+1).toString());
  _refreshController.loadComplete();
}

Widget scheduleWaiter(Widget inside) {
  return Scaffold(
    body: SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: ClassicHeader(),
      footer: CustomFooter(
        builder: (BuildContext context,LoadStatus mode) {
          Widget body;
          if(mode == LoadStatus.idle){
            body = Text("pull up load");
          }
          else if(mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          }
          else if(mode == LoadStatus.failed) {
            body = Text("Load Failed! Click retry!");
          }
          else if(mode == LoadStatus.canLoading) {
            body = Text("release to load more");
          }
          else {
            body = Text("No more Data");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: inside,
    ),
  );
}