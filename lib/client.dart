import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:gvid_app2/retrofit/apiICanteen.dart';
import 'package:gvid_app2/retrofit/apiSchoolOnline.dart';
import 'package:gvid_app2/retrofit/restICanteen.dart';
import 'package:gvid_app2/retrofit/restSchoolOnline.dart';


// school online works little weird
// it sends us through 3 different sites before letting us in
class RestSchoolOnlineInterceptor extends InterceptorsWrapper {
  RestSchoolOnline restSchoolOnline;
  RestSchoolOnlineInterceptor(this.restSchoolOnline);

  // follow redirect policy of school online
  @override
  Future onError(DioError err) async {
    final path = err.request.uri.path;
    if (path == '/SOL/prihlaseni.aspx') {
      return await restSchoolOnline.getDefault();
    }
    if (path == '/SOL/default.aspx') {
      return await restSchoolOnline.getDefault2();
    }
    if (path == '/SOL/App/Default.aspx') {
      return await restSchoolOnline.getOverview();
    }
    // other errors fallthrough
    return err; //continue
  }
}


class RestICanteenInterceptor extends InterceptorsWrapper {
  RestICanteen restICanteen;
  RestICanteenInterceptor(this.restICanteen);

  // follow redirect policy of school online
  @override
  Future onError(DioError err) async {
    final path = err.request.uri.path;
    if (path == '/j_spring_security_check') {
      return await restICanteen.getDefault();
    }
    //other errors fallthrough
    return err; //continue
  }
}


// client is the main class of backend
// it connects to different apis in order to download data
class Client {
  ApiSchoolOnline schoolOnline;
  ApiICanteen iCanteen;
  RestSchoolOnline _restSchoolOnline;
  RestICanteen _restICanteen;
  CookieManager _cookieManager;
  Dio _dio;

  Client() {
    _cookieManager = CookieManager(CookieJar());
    _dio = Dio();
    _restSchoolOnline = RestSchoolOnline(_dio);
    _restICanteen = RestICanteen(_dio);
    _dio.interceptors.add(_cookieManager);
    _dio.interceptors.add(RestSchoolOnlineInterceptor(_restSchoolOnline));
    _dio.interceptors.add(RestICanteenInterceptor(_restICanteen));
    schoolOnline = ApiSchoolOnline(_restSchoolOnline);
    iCanteen = ApiICanteen(_restICanteen);
  }
}
