// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restSchoolOnline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mark _$MarkFromJson(Map<String, dynamic> json) {
  return Mark(
    date: json['date'] as String,
    subjectName: json['subjectName'] as String,
    topic: json['topic'] as String,
    description: json['description'] as String,
    weight: json['weight'] as String,
    value: json['value'] as String,
  );
}

Map<String, dynamic> _$MarkToJson(Mark instance) => <String, dynamic>{
      'date': instance.date,
      'subjectName': instance.subjectName,
      'topic': instance.topic,
      'description': instance.description,
      'weight': instance.weight,
      'value': instance.value,
    };

Subject _$SubjectFromJson(Map<String, dynamic> json) {
  return Subject(
    name: json['name'] as String,
    fullName: json['fullName'] as String,
    teacher: json['teacher'] as String,
    classroom: json['classroom'] as String,
    date: json['date'] as String,
    duration: json['duration'] as int,
  );
}

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'name': instance.name,
      'fullName': instance.fullName,
      'teacher': instance.teacher,
      'classroom': instance.classroom,
      'date': instance.date,
      'duration': instance.duration,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestSchoolOnline implements RestSchoolOnline {
  _RestSchoolOnline(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    baseUrl ??= 'https://aplikace.skolaonline.cz';
  }

  final Dio _dio;

  String baseUrl;

  @override
  Future<String> login(eventTarget, field2, field3, field4, field5, field6,
      field7, field8, username, password, field11, field12, field13) async {
    ArgumentError.checkNotNull(eventTarget, 'eventTarget');
    ArgumentError.checkNotNull(field2, 'field2');
    ArgumentError.checkNotNull(field3, 'field3');
    ArgumentError.checkNotNull(field4, 'field4');
    ArgumentError.checkNotNull(field5, 'field5');
    ArgumentError.checkNotNull(field6, 'field6');
    ArgumentError.checkNotNull(field7, 'field7');
    ArgumentError.checkNotNull(field8, 'field8');
    ArgumentError.checkNotNull(username, 'username');
    ArgumentError.checkNotNull(password, 'password');
    ArgumentError.checkNotNull(field11, 'field11');
    ArgumentError.checkNotNull(field12, 'field12');
    ArgumentError.checkNotNull(field13, 'field13');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {
      '__EVENTTARGET': eventTarget,
      '__EVENTARGUMENT': field2,
      '__VIEWSTATE': field3,
      '__VIEWSTATEGENERATOR': field4,
      '__VIEWSTATEENCRYPTED': field5,
      '__PREVIOUSPAGE': field6,
      '__EVENTVALIDATION': field7,
      r'dnn$dnnSearch$txtSearch': field8,
      'JmenoUzivatele': username,
      'HesloUzivatele': password,
      'ScrollTop': field11,
      '__dnnVariable': field12,
      '__RequestVerificationToken': field13
    };
    _data.removeWhere((k, v) => v == null);
    final _result = await _dio.request<String>('/SOL/prihlaseni.aspx',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            contentType: 'application/x-www-form-urlencoded',
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }

  @override
  Future<String> getDefault() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<String>('/SOL/default.aspx',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }

  @override
  Future<String> getDefault2() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<String>('/SOL/App/Default.aspx',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }

  @override
  Future<String> getOverview() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<String>(
        '/SOL/App/Spolecne/KZZ010_RychlyPrehled.aspx',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }

  @override
  Future<String> getMarksDetailed() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<String>(
        '/SOL/App/Hodnoceni/KZH003_PrubezneHodnoceni.aspx',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }

  @override
  Future<String> getMarksSummary() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<String>(
        '/SOL/App/Hodnoceni/KZH001_HodnVypisStud.aspx',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }

  @override
  Future<String> getCalendar() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<String>(
        '/SOL/App/Kalendar/KZK001_KalendarTyden.aspx',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }
}
