import 'dart:core';
import 'dart:io';

import 'package:gvid_app2/retrofit/restICanteen.dart';
import 'package:gvid_app2/retrofit/restSchoolOnline.dart';

import 'client.dart';

void main() async {
  final client = Client();
  final schoolOnlineLogin = await client.schoolOnline.login('Username', 'Password');
  final iCanteenLogin = await client.iCanteen.login('Username', 'Password');

  print('--| Login Test |--');
  print('Login to schoolOnline: $schoolOnlineLogin');
  print('Login to iCanteenLogin: $iCanteenLogin');
  assert (schoolOnlineLogin && client.iCanteen.hasLogged);

  print('--| School Online Demo |--');
  print('Loading marks from web:');
  final marks = await client.schoolOnline.getMarksDetailed();
  final marksFile = await File('lib/demo_files/marks.json').create(recursive: true);
  final markJson = Mark.listToJson(marks);
  await marksFile.writeAsString(markJson);
  print(markJson);

  print('Loading marks from file:');
  final marksSaved = await marksFile.readAsString();
  final marksArray = Mark.listFromJson(marksSaved);
  marksArray.forEach((mark) => print(mark));

  print('Saving calendar from web');
  final calendar = await client.schoolOnline.getCalendar();
  final calendarFile = await File('lib/demo_files/calendar.json').create(recursive: true);
  final calendarJson = Subject.tableToJson(calendar);
  await calendarFile.writeAsString(calendarJson);
  print(calendarJson);

  print('Loading calendar from file:');
  final calendarSaved = await calendarFile.readAsString();
  final calendarArray = Subject.tableFromJson(calendarSaved);
  calendarArray.forEach((a) => print(a.map((b) => b?.name.toString().padRight(5)).join("")));

  print('--| School iCanteenLogin Demo |--');
  print('Loading food from web:');
  final foodWeek = await client.iCanteen.getWeek();
  final foodWeekFile = await File('lib/demo_files/foodWeek.json').create(recursive: true);
  await foodWeekFile.writeAsString(FoodOffer.listToJson(foodWeek));
  print(foodWeek);

  print('Loading food from file:');
  final foodWeekSaved = await foodWeekFile.readAsString();
  final foodWeekArray = FoodOffer.listFromJson(foodWeekSaved);
  foodWeekArray.forEach((foodOffer) => print(foodOffer));

  print('Loading food from 16.10.2020:');
  print(await client.iCanteen.getDay(DateTime(2020, 10, 16)));
  print('Loading food from 18.10.2020:');
  print(await client.iCanteen.getDay(DateTime(2020, 10, 18)));
  print('Ordering food at 23.10.2020:');
  print(await client.iCanteen.orderFood(DateTime(2020, 10, 23), 0));
  print('Unordering food at 23.10.2020:');
  print(await client.iCanteen.orderFood(DateTime(2020, 10, 23), 0));
  print('Ordering food at 25.10.2020 (should be empty):');
  print(await client.iCanteen.orderFood(DateTime(2019, 10, 25), 0));

  print('--| END |--');
  return;
}
