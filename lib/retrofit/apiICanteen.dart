import 'package:gvid_app2/retrofit/restICanteen.dart';
import 'package:html/parser.dart';


class ApiICanteen {
  bool hasLogged = false;
  RestICanteen restICanteen;
  ApiICanteen(this.restICanteen);

  // returns amount of user money or an empty string in case of error
  Future<String> login(String username, String password) async {
    final hash = parse(await restICanteen.getThisWeek()).getElementsByTagName('input')
        .firstWhere((element) => element.attributes['name'] == '_csrf').attributes['value'];
    final data = await restICanteen.login(username, password, 'false', 'web', hash)
        .catchError((interceptedData) => interceptedData.message);
    final credit = parse(data).getElementById('Kredit')?.text;
    hasLogged = credit != null;
    return credit ?? '';
  }

  String _dateToICanteen(DateTime time) {
    return '${time.year}-${time.month}-${time.day}';
  }

  void _foodSoupSplit(FoodOffer foodOffer, String text) {
    if (text.contains(';')) {
      final semicolon = text.indexOf(';');
      final splitted = [text.substring(0, semicolon), text.substring(semicolon + 1)];
      foodOffer.soup = splitted[0];
      text = splitted[1];
    }
    foodOffer.foods.add(text);
  }

  Future<FoodOffer> getDay(DateTime date) async {
    final data = await restICanteen.getDay(_dateToICanteen(date), 'false', 'false', 'false');
    final options = parse(data).getElementsByClassName('jidelnicekItem');
    var foodOffer = FoodOffer(soup: '', foods: List<String>(), order: -1, date: date);
    // iCanteen does not have named spans, go through them in order
    for (final option in options) {
      for (final child in option.children) {
        final button = child.children[0].getElementsByTagName('a').first;
        var food = child.children[1].text.replaceAll(RegExp(r'\s\s+'), '')
            .replaceAll(' ,', ',').replaceAll('(', ' (');
        // Save information for later order
        if (button.classes.contains('ordered')) {
          foodOffer.order = foodOffer.foods.length;
        }
        _foodSoupSplit(foodOffer, food);
      }
    }
    return foodOffer;
  }

  // ordering the same food twice will delete the offer
  // returns new total money in the bank or empty string
  Future<String> orderFood(DateTime date, int which) async {
    final newData = await restICanteen.getDay(_dateToICanteen(date), 'false', 'false', 'false');
    final buttons = parse(newData).getElementsByClassName('button-link-main')
        .where((element) => !element.classes.contains('disabled')).toList();
    if (which >= buttons.length) { return ''; }
    final buttonAddress = buttons[which].attributes['onclick'].trim();
    final address = RegExp(r"db\/dbProcessOrder.jsp[^']*").stringMatch(buttonAddress);
    final data = await restICanteen.order(address);
    return parse(data).getElementById('Kredit')?.text ?? '';
  }

  Future<List<FoodOffer>> getWeek() async {
    final data = await restICanteen.getThisWeek();
    final days = parse(data).getElementsByClassName('jidelnicekDen');
    final foodOffers = List<FoodOffer>();
    for (final day in days) {
      final date = day.getElementsByClassName('important').first.text.trim();
      final names = day.getElementsByTagName('div')
          .where((element) => element.attributes['style'] == 'padding: 2 0 2 20');
      names.forEach((name) => name.children.forEach((child) => child.remove()));
      final dateParts = date.split('.').map((d) => int.parse(d)).toList();
      var foodOffer = FoodOffer(soup: '', foods: List<String>(), order: -1,
          date: DateTime(dateParts[2], dateParts[1], dateParts[0]));
      for (final name in names) {
        name.children.forEach((child) => child.remove());
        var text = name.text.replaceAll('--', '').trim();
        _foodSoupSplit(foodOffer, text);
      }
      foodOffers.add(foodOffer);
    }
    return foodOffers;
  }
}


