import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gvid_app2/frontend_widgets/schedule.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:gvid_app2/retrofit/restSchoolOnline.dart';
import 'package:path_provider/path_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
  = FlutterLocalNotificationsPlugin();

final details = const NotificationDetails(
  android: AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    'your channel description',
    channelShowBadge: false,
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker'
  )
);

void zonedScheduleNotification(List<String> notification, tz.TZDateTime when, int id) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      notification[0],
      "${notification[1]} - ${notification[2]}",
      when,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime
  );
}

void scheduleWeeksNotifications(List<List<Subject>> scheduleTable) async {
  var now = tz.TZDateTime.now(tz.local);
  final weekday = now.weekday;
  final priorMinutes = 20;

  if (weekday == 6) {
    now = now.add(Duration(days: 2));
  } else if(weekday == 7) {
    now = now.add(Duration(days: 1));
  }

  var countId = 0;
  await flutterLocalNotificationsPlugin.show(countId++, 'GvidApp2 Notifikace',
      'Do konce týdne dostaneš notifikace o hodinách.', details);
  for(int i = now.weekday; i <= 5; i++) {
    final dayNotifications = createLessonTimes(i - 1, scheduleTable);
    for(int j = 0; j < dayNotifications.length; j++) {
      final start = dayNotifications[j][0].split(" - ").first;
      final startHours = int.parse(start.split(":").first);
      final startMinutes = int.parse(start.split(":").last);
      var notificationTime = tz.TZDateTime.local(now.year, now.month,
          now.day + i - now.weekday, startHours, startMinutes - priorMinutes);
      if (notificationTime.difference(now) > Duration.zero) { // is notification in the future?
        zonedScheduleNotification(dayNotifications[j], notificationTime, countId++);
      }
    }
  }
}

List<List<String>> createLessonTimes(int monToFri, List<List<Subject>> scheduleTable) {
  final startingTimes = [ "7:05 - 7:50", "8:00 - 8:45",
    "8:55 - 9:40", "9:55 - 10:40", "10:50 - 11:35",
    "11:45 - 12:30", "12:40 - 13:25", "13:30 - 14:15",
    "14:20 - 15:05", "15:10 - 15:55", "16:00 - 16:45" ];
  final scheduleDay = scheduleTable[monToFri];
  final notificationTimes = List<List<String>>();
  for (int i = 0; i < scheduleDay.length; i++) {
    final subject = scheduleDay[i];
    if(subject != null) {
      notificationTimes.add([]);
      if(subject.duration == 2) {
        notificationTimes.last.add("${startingTimes[i].split(" - ").first}"
            " - ${startingTimes[i + 1].split(" - ").last}");
        //"9:55 - 10:40" + "10:50 - 11:35" -> "9:55 - 11:35"
        i++;
      } else {
        notificationTimes.last.add(startingTimes[i]);
      }
      notificationTimes.last.add(subject.name);
      notificationTimes.last.add(subject.classroom.split("-").first);
    }
  }
  return notificationTimes;
}

Future<bool> createNotifications(bool corona) async {
  final directory = await getApplicationDocumentsDirectory();
  final scheduleFile = File("${directory.path}/calendar.json");
  if (!(await scheduleFile.exists())) {
    return false;
  }
  final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: IOSInitializationSettings()
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Europe/Prague"));
  final scheduleString = await scheduleFile.readAsString();
  final table = Subject.tableFromJson(scheduleString);
  scheduleWeeksNotifications(!corona ? table : createCoronaSchedule(table));
  return true;
}