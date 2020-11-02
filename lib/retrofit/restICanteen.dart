import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'restICanteen.g.dart';

@JsonSerializable(nullable: false)
class FoodOffer {
  String soup; // '' if no soup was found
  List<String> foods; // [] if no food was found (e.g. weekend)
  int order; // -1 if no food is chosen
  DateTime date; // date of offer
  FoodOffer({@required this.soup, @required this.foods, @required this.order, @required this.date});
  factory FoodOffer.fromJson(Map<String, dynamic> json) => _$FoodOfferFromJson(json);
  Map<String, dynamic> toJson() => _$FoodOfferToJson(this);

  static String listToJson(List<FoodOffer> foodOffers) =>
    jsonEncode(foodOffers.map((foodOffer) => foodOffer.toJson()).toList());

  static List<FoodOffer> listFromJson(String list) =>
      jsonDecode(list).map((foodOffer) => FoodOffer.fromJson(foodOffer))
          .toList().cast<FoodOffer>();

  @override
  String toString() => "FoodOffer{[soup]: {$soup}, [foods]: "
      "{${foods.join('}, {')}}, [order]: $order, [date]: $date}";
}

// CANTEEN ONLINE API
@RestApi(baseUrl: 'http://jidelna.gvid.cz')
abstract class RestICanteen {
  factory RestICanteen(Dio dio, {String baseUrl}) = _RestICanteen;

  @GET('/faces/login.jsp')
  Future<String> getThisWeek();

  @POST('/j_spring_security_check')
  @FormUrlEncoded()
  Future<String> login(
      @Field('j_username') String username,
      @Field('j_password') String password,
      @Field('terminal') String terminal,
      @Field('type') String type,
      @Field('_csrf') String hash,
      );

  @GET('/faces/secured/main.jsp')
  Future<String> getDefault();

  @GET('/faces/secured/main.jsp')
  Future<String> getDay(
      @Query('day') String yearMonthDay,
      @Query('terminal') String terminal,
      @Query('printer') String printer,
      @Query('keyboard') String keyboard
  );

  @GET('http://jidelna.gvid.cz/faces/secured/{path}')
  Future<String> order(@Path("path") String path);
}
