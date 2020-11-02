import 'dart:convert';

import 'package:retrofit/retrofit.dart' as retrofit;
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'restSchoolOnline.g.dart';


@JsonSerializable(nullable: false)
class Mark {
  String date; // 18.09.2020
  String subjectName; // Matematika
  String topic; // 1.minutka - teorie čísel
  String description; // my town
  String weight; // 0.5
  String value; // 2

  Mark({@required this.date, @required this.subjectName, @required this.topic,
    @required this.description, @required this.weight, @required this.value});

  factory Mark.fromJson(Map<String, dynamic> json) => _$MarkFromJson(json);
  Map<String, dynamic> toJson() => _$MarkToJson(this);

  static String listToJson(List<Mark> marks) =>
      jsonEncode(marks.map((mark) => mark.toJson()).toList());

  static List<Mark> listFromJson(String list) =>
      jsonDecode(list).map((mark) => Mark.fromJson(mark)).toList().cast<Mark>();

  @override
  String toString() => 'Mark{[date]: $date, [subjectName]: $subjectName, [topic]: $topic, '
        '[description]: $description, [weight]: $weight, [value]: $value}';
}


@JsonSerializable(nullable: false)
class Subject {
  String name; // Aj
  String fullName; // Anglický Jazyk
  String teacher; // Bukvaldová J.
  String classroom; // 209-HV
  String date; // Po 5.10. (4)
  int duration; // 1

  Subject({@required this.name, @required this.fullName, @required this.teacher,
    @required this.classroom, @required this.date, @required this.duration});

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectToJson(this);

  static String tableToJson(List<List<Subject>> subjects) =>
      jsonEncode(subjects.map((subjectColumn) => subjectColumn.map((subject) =>
          subject?.toJson()).toList()).toList());

  static List<List<Subject>> tableFromJson(String list) =>
      jsonDecode(list).map((subjectColumn) => subjectColumn.map((subject) =>
          (subject != null) ? Subject.fromJson(subject) : null)
              .toList().cast<Subject>()).toList().cast<List<Subject>>();

  @override
  String toString() => 'Subject{[name]: $name, [fullname]: $fullName, [teacher]: '
      '$teacher, [classroom]: $classroom, [date]: $date, [duration]: $duration}';
}


// SCHOOL ONLINE API
@retrofit.RestApi(baseUrl: 'https://aplikace.skolaonline.cz')
abstract class RestSchoolOnline {
  factory RestSchoolOnline(Dio dio, {String baseUrl}) = _RestSchoolOnline;

  // initiate authorize
  @retrofit.POST('/SOL/prihlaseni.aspx')
  @retrofit.FormUrlEncoded()
  Future<String> login(
      @retrofit.Field('__EVENTTARGET') String eventTarget,
      @retrofit.Field('__EVENTARGUMENT') String field2,
      @retrofit.Field('__VIEWSTATE') String field3,
      @retrofit.Field('__VIEWSTATEGENERATOR') String field4,
      @retrofit.Field('__VIEWSTATEENCRYPTED') String field5,
      @retrofit.Field('__PREVIOUSPAGE') String field6,
      @retrofit.Field('__EVENTVALIDATION') String field7,
      @retrofit.Field(r'dnn$dnnSearch$txtSearch') String field8,
      @retrofit.Field('JmenoUzivatele') String username,
      @retrofit.Field('HesloUzivatele') String password,
      @retrofit.Field('ScrollTop') String field11,
      @retrofit.Field('__dnnVariable') String field12,
      @retrofit.Field('__RequestVerificationToken') String field13
  );

  // first authorize
  @retrofit.GET('/SOL/default.aspx')
  Future<String> getDefault();

  // second authorize
  @retrofit.GET('/SOL/App/Default.aspx')
  Future<String> getDefault2();

  // test authorization
  @retrofit.GET('/SOL/App/Spolecne/KZZ010_RychlyPrehled.aspx')
  Future<String> getOverview();

  // get all marks
  @retrofit.GET('/SOL/App/Hodnoceni/KZH003_PrubezneHodnoceni.aspx')
  Future<String> getMarksDetailed();

  // get overall stats
  // not implemented in api!
  @retrofit.GET('/SOL/App/Hodnoceni/KZH001_HodnVypisStud.aspx')
  Future<String> getMarksSummary();

  // get calendar
  @retrofit.GET('/SOL/App/Kalendar/KZK001_KalendarTyden.aspx')
  Future<String> getCalendar();
}
