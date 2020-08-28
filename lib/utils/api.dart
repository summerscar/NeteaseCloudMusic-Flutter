import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

Dio Function() api = (() {
  BaseOptions options = new BaseOptions(
    baseUrl: "https://music.api.summerscar.me",
    connectTimeout: 10000,
    receiveTimeout: 10000,
);

  final dio =  Dio(options);
  var cookieJar=CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));
  // Print cookies
  // second request with the cookie
  return () => dio;
})();
