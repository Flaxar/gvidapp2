// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restICanteen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodOffer _$FoodOfferFromJson(Map<String, dynamic> json) {
  return FoodOffer(
    soup: json['soup'] as String,
    foods: (json['foods'] as List).map((e) => e as String).toList(),
    order: json['order'] as int,
    date: DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$FoodOfferToJson(FoodOffer instance) => <String, dynamic>{
      'soup': instance.soup,
      'foods': instance.foods,
      'order': instance.order,
      'date': instance.date.toIso8601String(),
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestICanteen implements RestICanteen {
  _RestICanteen(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    baseUrl ??= 'http://jidelna.gvid.cz';
  }

  final Dio _dio;

  String baseUrl;

  @override
  Future<String> getThisWeek() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<String>('/faces/login.jsp',
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
  Future<String> login(username, password, terminal, type, hash) async {
    ArgumentError.checkNotNull(username, 'username');
    ArgumentError.checkNotNull(password, 'password');
    ArgumentError.checkNotNull(terminal, 'terminal');
    ArgumentError.checkNotNull(type, 'type');
    ArgumentError.checkNotNull(hash, 'hash');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {
      'j_username': username,
      'j_password': password,
      'terminal': terminal,
      'type': type,
      '_csrf': hash
    };
    _data.removeWhere((k, v) => v == null);
    final _result = await _dio.request<String>('/j_spring_security_check',
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
    final _result = await _dio.request<String>('/faces/secured/main.jsp',
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
  Future<String> getDay(yearMonthDay, terminal, printer, keyboard) async {
    ArgumentError.checkNotNull(yearMonthDay, 'yearMonthDay');
    ArgumentError.checkNotNull(terminal, 'terminal');
    ArgumentError.checkNotNull(printer, 'printer');
    ArgumentError.checkNotNull(keyboard, 'keyboard');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'day': yearMonthDay,
      r'terminal': terminal,
      r'printer': printer,
      r'keyboard': keyboard
    };
    final _data = <String, dynamic>{};
    final _result = await _dio.request<String>('/faces/secured/main.jsp',
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
  Future<String> order(path) async {
    ArgumentError.checkNotNull(path, 'path');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<String>(
        'http://jidelna.gvid.cz/faces/secured/$path',
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
