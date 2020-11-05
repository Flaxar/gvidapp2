import 'dart:core';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

// every API must be enabled via https://console.developers.google.com/apis/api/classroom.googleapis.com/overview?project=gvid-app, otherwise it will not be available
// and http requests will fail with "DetailedApiRequestError(status: 403, message: Google Classroom API has not been used in project ..." message.
import 'package:googleapis/classroom/v1.dart' as classroom;

import 'google_signin/sign_in.dart';
import 'webLoader.dart';

// see https://stackoverflow.com/questions/48477625/how-to-use-google-api-in-flutter/48485898#48485898
class AuthenticateClient extends http.BaseClient {
  final Map<String, String> headers;
  final http.Client client;
  AuthenticateClient(this.headers, this.client);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return client.send(request..headers.addAll(headers));
  }
}

// suplovani:
class GoogleClassroomSuplyWidget extends StatefulWidget {
  @override
  _GoogleClassroomSuplyState createState() => _GoogleClassroomSuplyState();
}

class _GoogleClassroomSuplyState extends State<GoogleClassroomSuplyWidget> {
  @override
  Widget build(BuildContext context) {
    return _suplyData();
  }
}

class SuplyData {
  String nazev;
  String popis;
  String souborNazev;
  String souborPreviewUrl;
  String souborUrl;
  SuplyData(this.nazev, this.popis, this.souborNazev, this.souborPreviewUrl, this.souborUrl);
}

class SuplyWebLoad {
  Future<List<SuplyData>> load() async {
    if (googleUser == null) {
      return Future.error('Not logged in to google');
    }

    final baseClient = new http.Client();
    final httpClient = AuthenticateClient({
      'Authorization': 'Bearer ${googleTokens.accessToken}'
    }, baseClient);
    final classroomApi = classroom.ClassroomApi(httpClient);
    // see https://developers.google.com/classroom/reference/rest/v1/courses/list
    var res = await classroomApi.courses.list(courseStates: ['ACTIVE']);

    List<SuplyData> ret = [];
    List data = res?.courses;
    for (var c in data ?? []) {
      if (c.name == 'Nástěnka') { // Suplování se hledá jen v pomocném 'předmětu' s tímto názvem
        var res = await classroomApi.courses.courseWorkMaterials.list(c.id);
        for (var m in res?.courseWorkMaterial ?? []) { // materiály k tomuto předmětu
          //print(" m=${json.encode(m)}");
          for (var soubor in m.materials ?? []) { // soubory k tomuto materiálu
            // soubor={"driveFile":{"driveFile":{"alternateLink":"https://drive.google.com/open?id=1a5ODp8wB_ji9QVbBhVF5j_p5Ujs84JYR","id":"1a5ODp8wB_ji9QVbBhVF5j_p5Ujs84JYR","thumbnailUrl":"https://drive.google.com/thumbnail?id=1a5ODp8wB_ji9QVbBhVF5j_p5Ujs84JYR&sz=s200","title":"IMG_20201024_165419.jpg"},"shareMode":"VIEW"}}
            if (RegExp(r'supl', caseSensitive: false).hasMatch(
                m.title)) { // pouze text 'supl'
              ret.add(new SuplyData(
                  m.title, m.description,
                  soubor.driveFile.driveFile.title,
                  soubor.driveFile.driveFile.thumbnailUrl,
                  soubor.driveFile.driveFile.alternateLink));
            }
          }
        }
      }
    }
    print(ret);
    return ret;
  }
}

FutureBuilder _suplyData(){
  return FutureBuilder<List<dynamic>>(
    future: SuplyWebLoad().load(),
    builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot){
      if (snapshot.hasData) {
        return _suply(snapshot.data);
      } else if (snapshot.hasError) {
        return Text("${snapshot.error}");
      }
      return createLoadingCircle('Loading substitutions');
    },
  );
}

ListView _suply(List<SuplyData> data) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var d = data[index];
        return Card(
            child: _suplyTile(d)
        );
      }
  );
}

ListTile _suplyTile(SuplyData d) {
  //print("url=${d.souborPreviewUrl}");
  return ListTile(
    tileColor: Color.fromRGBO(61, 88, 133, 0.3),
    dense: false,
    title: Text(d.nazev,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
    )),
    // subtitle: Text(d.popis ?? ''),
    onTap: () {
      launchWeb(d.souborUrl);
    },
    
    // leading: Icon(
    //   icon,
    //   color: Colors.blue[500],
    // ),
  );
}

launchWeb(String URL) async
{
  if (await canLaunch(URL)) {
    await launch(URL);
  } else {
    throw 'Could not launch $URL';
  }
}

// classroom obecně:
class GoogleClassroomWidget extends StatefulWidget {
  @override
  _GoogleClassroomState createState() => _GoogleClassroomState();
}

class _GoogleClassroomState extends State<GoogleClassroomWidget> {
  @override
  Widget build(BuildContext context) {
    return _classroomData();
  }
}

class UkolyData {
  String id;
  String nazev;
  String url;
  double maxBodu;
  String trida;
  DateTime termin_odevzdani;
  UkolyData(this.id, this.nazev, this.url, this.maxBodu, this.trida, this.termin_odevzdani);
}

class ClassroomWebLoad {
  Future<List<UkolyData>> load() async {
    if (googleUser == null) {
      return Future.error('Not logged in to google');
    }

    final baseClient = new http.Client();
    final httpClient = AuthenticateClient({
      'Authorization': 'Bearer ${googleTokens.accessToken}'
    }, baseClient);
    final classroomApi = classroom.ClassroomApi(httpClient);
    // see https://developers.google.com/classroom/reference/rest/v1/courses/list
    var res = await classroomApi.courses.list(courseStates: ['ACTIVE']);
    //print("result=${json.encode(res)}");

    List<UkolyData> ret = [];
    List data = res?.courses;
    for (var c in data ?? []) {
      //print("a");
      if (c.name != 'Nástěnka') { // Úkoly odkudkoli kromě nástěnky
        //print("b");
        var res = await classroomApi.courses.courseWork.list(
            c.id, courseWorkStates: ['PUBLISHED']);
        for (var cw in res?.courseWork ?? []) { // úkoly k tomuto předmětu
          //print("c");
          //print(" cw=${json.encode(cw)}");
          // I/flutter (21198):  cw={"alternateLink":"https://classroom.google.com/c/MTU3MjM1MTM2NDI2/a/MTU3MjM2MTczNDU0/details","courseId":"157235136426","creationTime":"2020-10-27T19:04:02.625Z","creatorUserId":"112776978648777156578","dueDate":{"day":29,"month":10,"year":2020},"dueTime":{"hours":22,"minutes":59},"id":"157236173454","maxPoints":100.0,"state":"PUBLISHED","submissionModificationMode":"MODIFIABLE_UNTIL_TURNED_IN","title":"Úkol v matematice 2","updateTime":"2020-10-27T19:04:02.150Z","workType":"ASSIGNMENT"}
          // I/flutter (21198):  cw={"alternateLink":"https://classroom.google.com/c/MTU3MjM1MTM2NDI2/a/MTU3MjMyOTAwMTAy/details","courseId":"157235136426","creationTime":"2020-10-27T19:03:36.809Z","creatorUserId":"112776978648777156578","dueDate":{"day":31,"month":10,"year":2020},"dueTime":{"hours":22,"minutes":59},"id":"157232900102","maxPoints":100.0,"state":"PUBLISHED","submissionModificationMode":"MODIFIABLE_UNTIL_TURNED_IN","title":"Úkol v matematice","updateTime":"2020-10-27T19:03:36.363Z","workType":"ASSIGNMENT"}

          if (cw.workType != 'ASSIGNMENT') { // nejde-li o úkol, přeskočit
            continue;
          }

          //print("d");
          // jen neodevzdané úkoly:
          bool odevzdano = false;
          // TURNED_IN = odevzdano
          // RETURNED = odevzdano a navic i ohodnoceno ucitelem
          var res = await classroomApi.courses.courseWork.studentSubmissions
              .list(c.id, cw.id, states: ['TURNED_IN', 'RETURNED']);
          //print("e");
          for (var s in res?.studentSubmissions ?? []) { // stav odevzdání úkolu
            odevzdano = true;
            break; // netřeba dál testovat
          }

          //print("e");
          if (!odevzdano) {
            //print("f");
            //print("c=${json.encode(c)}");
            //print("cw=${json.encode(cw)}");
            ret.add(new UkolyData(
                cw.id, cw.title, cw.alternateLink,
                cw.maxPoints,
                c.name, // název třídy, které se úkol týká
                new DateTime(
                    cw.dueDate?.year ?? 2199, cw.dueDate?.month ?? 12, cw.dueDate?.day ?? 31,
                    cw.dueTime?.hours ?? 0, cw.dueTime?.minutes ?? 59)));
          }
          //print("Jsem tu 1 $ret");
        }
        //print("Jsem tu 2 $ret");
      }
      //print("Jsem tu 3 $ret");
    }
    //print("Jsem tu 4 $ret");
    // seřadit výsledek dle limitního data odevzdání, od nejdřívějšího k nejpozdějšímu:
    ret.sort((a,b) => a.termin_odevzdani.compareTo(b.termin_odevzdani));

    //print("Jsem tu 5 $ret");
    return ret;
  }
}

FutureBuilder _classroomData(){
  return FutureBuilder<List<dynamic>>(
    future: ClassroomWebLoad().load(),
    builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot){
      if (snapshot.hasData) {
        return _classroom(snapshot.data);
      } else if (snapshot.hasError) {
        return Text("${snapshot.error}");
      }
      return createLoadingCircle('Loading assignments');
    },
  );
}

ListView _classroom(List<UkolyData> data) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var d = data[index];
        return Card(
            child: _classroomTile(d)
        );
      }
  );
}

ListTile _classroomTile(UkolyData d) {
  //print("url=${d.url}");

  var now = DateTime.now();
  var diff = d.termin_odevzdani.difference(now);
  var times = d.termin_odevzdani;

  var cele_dny = (diff.inHours / 24).toInt();
  var cele_hodiny = diff.inHours - 24*cele_dny;
  //print("diff=${diff}, ${diff.inDays}, ${diff.inHours}, ${diff.isNegative}, $cele_dny, $cele_hodiny");

  var zbyva_txt = '';
  if (cele_dny > 0) {
    zbyva_txt += "Odevzdat za $cele_dny ";
    if (cele_dny >= 5) {
      zbyva_txt += "dní";
    } else if (cele_dny >= 2) {
      zbyva_txt += "dny";
    } else {
      zbyva_txt += "den";
    }
  };
  if (cele_hodiny > 0) {
    if (zbyva_txt == '') {
      zbyva_txt += "Odevzdat za ";
    } else {
      zbyva_txt += " a ";
    };
    zbyva_txt += "$cele_hodiny ";
    if (cele_hodiny >= 5) {
      zbyva_txt += "hodin";
    } else if (cele_hodiny >= 2) {
      zbyva_txt += "hodiny";
    } else {
      zbyva_txt += "hodinu";
    }
  };
  if (zbyva_txt == '') {
    zbyva_txt += "Již mělo být odevzdáno";
  }

  var msgDate;
  if(times.hour == 22) {
    msgDate = DateFormat('dd. MM. yyyy').format(d.termin_odevzdani);
  } else {
    msgDate = DateFormat('dd. MM. yyyy kk:mm').format(d.termin_odevzdani);
  }

  return ListTile(
    tileColor: Color.fromRGBO(61, 88, 133, 0.3),
    dense: false,
    title: Text(d.nazev,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
        )),
    subtitle: Text("${d.trida}\n\n$zbyva_txt ($msgDate)"),

    // leading: Icon(
    //   icon,
    //   color: Colors.blue[500],
    // ),
    onTap: () {
      launchWeb(d.url); // odkaz na konkrétní úkol
    },

  );
}
