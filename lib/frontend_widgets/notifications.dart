import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:gvid_app2/retrofit/restSchoolOnline.dart';
import 'package:path_provider/path_provider.dart';

const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

final initializationSettings = InitializationSettings(
  android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  iOS: IOSInitializationSettings()
);

Future selectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  // await Navigator.push(
  //   context,
  //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  // );
}

Future<bool> initNotification() async {
   return await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}

tz.TZDateTime _nextInstanceOfTenAM() {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = now.add(Duration(seconds: 5));
  // tz.TZDateTime(tz.local, now.year, now.month, now.day, now.hour, now.minute, now.second);
  // if (scheduledDate.isBefore(now)) {
  //   scheduledDate = scheduledDate.add(const Duration(seconds: 5));
  // }
  return scheduledDate;
}

Future<void> configureLocalTimeZone() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Europe/Prague"));
}

Future<void> zonedScheduleNotification(List<String> notification, tz.TZDateTime when, int id) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      notification[0],
      "${notification[1]} - ${notification[2]}",
      when,
      const NotificationDetails(
          android: AndroidNotificationDetails(
              'your channel id',
              'your channel name',
              'your channel description',
              channelShowBadge: false,
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime);
}


Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, 'plain title', 'plain body', platformChannelSpecifics,
      payload: 'item x');
}

class Notifications {
  final startingTimes = ["7:05 - 7:50", "8:00 - 8:45",
    "8:55 - 9:40", "9:55 - 10:40", "10:50 - 11:35",
    "11:45 - 12:30", "12:40 - 13:25", "13:30 - 14:15",
    "14:20 - 15:05", "15:10 - 15:55", "16:00 - 16:45"
  ];
  List<List<Subject>> scheduleTable;
  var notificationTimesCorona = [];
  int numOfDayNotifications;

  Future<void> scheduleWeeksNotifications() async {
    int count = 0;
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final weekday = now.weekday;

    if(weekday == 6) {
      now = now.add(Duration(days: 2));
    } else if(weekday == 7) {
      now = now.add(Duration(days: 1));
    }

    for(int i = now.weekday - 1; i < 5; i++) {
      final dayNotifications = createLessonTimes(i);

      for(int j = 0; j < numOfDayNotifications; j++) {
        count++;
        final start = dayNotifications[j][0].split(" - ").first;
        final startHours = int.parse(start.split(":").first);
        final startMinutes = int.parse(start.split(":").last);
        var notifTime = tz.TZDateTime.local(now.year, now.month,
            now.day + i - now.weekday + 1, startHours, startMinutes - 20);

        //print("Day $i, Class $j, Notification $notifTime"); - debug notifications

        await zonedScheduleNotification(dayNotifications[j], notifTime, count);
      }
    }
  }

  List<List<String>> createLessonTimes(int monToFri) {
    final scheduleDay = scheduleTable[monToFri];
    final notificationTimes = List<List<String>>();
    for (int i = 0; i < scheduleDay.length; i++) {
      final subject = scheduleDay[i];
      if(subject != null) {
        notificationTimes.add([]);
        if(subject.duration == 2) {
          notificationTimes.last.add("${startingTimes[i].split(" - ").
          first} - ${startingTimes[i + 1].split(" - ").last}");
          //"9:55 - 10:40" + "10:50 - 11:35" -> "9:55 - 11:35"
          i++;
        } else {
          notificationTimes.last.add(startingTimes[i]);
        }
        notificationTimes.last.add(subject.name);
        notificationTimes.last.add(subject.classroom.split("-").first);
      }
    }
    numOfDayNotifications = notificationTimes.length;
    return notificationTimes;
  }

  Future<void> loadSchedule() async {
    final directory = await getApplicationDocumentsDirectory();
    final scheduleFile = File("${directory.path}/calendar.json");
    if(await scheduleFile.exists()) {
      final scheduleString = await scheduleFile.readAsString();
      scheduleTable = Subject.tableFromJson(scheduleString);
    }
  }
}