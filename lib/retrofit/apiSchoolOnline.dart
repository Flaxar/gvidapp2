import 'package:gvid_app2/retrofit/restSchoolOnline.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class ApiSchoolOnline {
  RestSchoolOnline restSchoolOnline;
  ApiSchoolOnline(this.restSchoolOnline);

  Future<bool> login(String username, String password) async {
    String data = await restSchoolOnline.login(r'dnn$ctr994$SOLLogin$btnODeslat',
        '', '', '', '', '', '', '', username, password, '', '', '')
        .catchError((interceptedData) => interceptedData.message);
    final title = parse(data).getElementsByTagName('title');
    return title.isNotEmpty ? title.first.text.contains('Rychlý přehled') : false;
  }

  Future<List<Mark>> getMarksDetailed() async {
    final data = await restSchoolOnline.getMarksDetailed();
    final table = parse(data).getElementById('ctl00xmainxgridHodnoceni_main');
    // parse html, find table elements and put them to list
    final getData = (elements) => elements.map((element) => element.text).toList();
    final dates = getData(table.getElementsByClassName(r'ig_dc2d1f6b_7 UWGOddCol'));
    final subjects = getData(table.getElementsByClassName(r'ig_dc2d1f6b_9 UWGEvenCol'));
    final topics = getData(table.getElementsByClassName(r'ig_dc2d1f6b_11 UWGOddCol'));
    final descriptions = getData(table.getElementsByClassName(r'ig_dc2d1f6b_17 UWGEvenCol'));
    final weights = getData(table.getElementsByClassName(r'ig_dc2d1f6b_13 UWGEvenCol'));
    final values = getData(table.getElementsByClassName(r'ig_dc2d1f6b_15 UWGOddCol'));
    // merge multiple lists to one
    final marks = List<Mark>();
    for (int i = 0; i < dates.length; i++) {
      marks.add(Mark(
          date: dates[i],
          subjectName: subjects[i],
          topic: topics[i],
          description: descriptions[i],
          weight: weights[i],
          value: values[i]
      ));
    }
    return marks;
  }

  Subject _convertSubject(Element element) {
    final mouseover = element.attributes['onmouseover'];
    final str = mouseover.substring('onMouseOverTooltip('.length, mouseover.length-1);
    final elements = str.split(RegExp(r'~|Učitel'));
    final bothNames = elements[0].substring(1, elements[0].length-4);
    final shortName = RegExp(r'([^(]*) \(').firstMatch(bothNames).group(1);
    final fullName = RegExp(r'\(([^)]*)\)').firstMatch(bothNames).group(1);
    final style = element.parentNode.parentNode.parentNode.attributes['style'];
    final duration = int.parse(RegExp(r'max-width:(\d+)px;').firstMatch(style).group(1));
    return Subject(fullName: fullName, name: shortName, teacher: elements[2],
        classroom: elements[8], date: elements[12], duration: duration~/78);
  }

  // returns 5x10 table of subjects, empty subjects will be null
  // WARNING: costly operation, user should not call this operation often
  Future<List<List<Subject>>> getCalendar() async {
    final data = await restSchoolOnline.getCalendar();
    final table = parse(data).getElementById('CCADynamicCalendarTable');
    final subjects = table.getElementsByClassName('DctInnerTableType10DataTD')
        .map((element) => _convertSubject(element)).toList();
    final calendar = List<List<Subject>>.generate(5, (_) => new List<Subject>(10));
    for (final subject in subjects) {
      final day = ['Po', 'Út', 'St', 'Čt', 'Pá'].indexWhere((element) => subject.date.contains(element));
      final hour = int.parse(RegExp(r'\((\d+)\)').firstMatch(subject.date).group(1));
      calendar[day][hour] = subject;
    }
    return calendar;
  }
}


