import 'package:flutter/material.dart';
import 'package:gvid_app2/webLoader.dart';
import 'package:gvid_app2/client.dart';
import 'package:gvid_app2/retrofit/restICanteen.dart';
import 'package:preferences/preferences.dart';

final client = Client();
final filename = "foods.json";

class Foods extends WebLoader<List<FoodOffer>> {
  Future<List<FoodOffer>> download() async {
    await client.iCanteen.login(PrefService.getString('food_login'), PrefService.getString('food_password'));

    List<FoodOffer> foodWeek;
    if (!client.iCanteen.hasLogged) {
      // if not logged, load default week
      foodWeek = await client.iCanteen.getWeek();
    }
    else {
      // load week with individual orders
      foodWeek = List<FoodOffer>();
      for (final day in getWeekdays()) {
        foodWeek.add(await client.iCanteen.getDay(day));
      }
    }
    saveToFile(filename, FoodOffer.listToJson(foodWeek));
    return foodWeek;
  }

  Future<List<FoodOffer>> load() async {
    final foodOffers = await loadFromFile(filename);
    return (foodOffers.isNotEmpty) ? FoodOffer.listFromJson(foodOffers) : download();
  }

  Widget success(List<FoodOffer> offers) {
    var list = List<Widget>();
    for(final offer in offers) {
      if(offer.foods.length != 0) {
        list.add(createDayName(offer.date));
        list.add(FoodButtons(offer));
        list.add(Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0)
        ));
      }
    }
    // empty listview with shrinkWrap set to true trows an error
    return Column(children: list);
  }

  @override
  Widget waiting() {
    return createLoadingCircle('Loading food');
  }

  @override
  Widget failure() {
    return createErrorText('Jidelna Error');
  }
}

class FoodButtons extends StatefulWidget  {
  final FoodOffer offer;
  FoodButtons(this.offer);

  @override
  _FoodButtonsState createState() => _FoodButtonsState(offer);
}

class _FoodButtonsState extends State<FoodButtons> {
  FoodOffer offer;
  _FoodButtonsState(this.offer);

  void onPressed(int i) async {
    if (client.iCanteen.hasLogged) {
      final beforeOrdered = offer.order;
      setState(() => offer.order = offer.order != i ? i : -1);
      if ((await client.iCanteen.orderFood(offer.date, i)).isEmpty) {
        setState(() => offer.order = beforeOrdered);
      }
    } else {
      print('Not Logged!');
    }
  }

  @override
  Widget build(BuildContext context){
    var list = List<Widget>();
    for (var i = 0; i < offer.foods.length; i++) {
      list.add(
        ButtonTheme(
          minWidth: 400,
          height: 50,
          child: FlatButton(
            onPressed: () => onPressed(i),
            textColor: Colors.white,
            hoverColor: Colors.black,
            color: i == offer.order ? Color.fromRGBO(47, 128, 74, 1) : Color.fromRGBO(61, 88, 133, 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
                side: BorderSide(color: Colors.black, width: 1)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              child: offer.foods[i].isEmpty ? Text('Parse error') : Text(offer.foods[i]),
            ),
          ),
        )
      );
      list.add(Container(
          margin: EdgeInsets.symmetric(vertical: 3, horizontal: 0)
      ));
    }
    return Column(children: list);
  }
}

Widget createDayName(DateTime foodDay) {
  final weekdaysList = [
    "Pondělí",
    "Úterý",
    "Středa",
    "Čtvrtek",
    "Pátek"
  ];
  final weekdayString = weekdaysList[foodDay.weekday - 1];

  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
        "$weekdayString  -  ${foodDay.day}. ${foodDay.month}.",
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
        )
    ),
  );
}

DateTime getNearestMonday() {
  DateTime date = new DateTime.now();
  DateTime monday;
  switch(date.weekday) {
    case 1: {
      monday = date;
    }
    break;

    case 2: {
      monday = date.subtract(new Duration(days: 1));
    }
    break;

    case 3: {
      monday = date.subtract(new Duration(days: 2));
    }
    break;

    case 4: {
      monday = date.subtract(new Duration(days: 3));
    }
    break;

    case 5: {
      monday = date.subtract(new Duration(days: 4));
    }
    break;

    case 6: {
      monday = date.add(new Duration(days: 2));
    }
    break;

    case 7: {
      monday = date.add(new Duration(days: 1));
    }
    break;
  }
  return monday;
}

List<DateTime> getWeekdays() {
  DateTime monday = getNearestMonday();
  List<DateTime> week = [];

  for(int i = 0; i < 5; i++) {
    week.add(monday.add(new Duration(days: i)));
  }

  for(int i = 0; i < 5; i++) {
    week.add(monday.add(new Duration(days: i + 7)));
  }
  return week;
}
