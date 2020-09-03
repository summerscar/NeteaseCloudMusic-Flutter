import 'dart:developer';

import 'package:dio/dio.dart';

import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

Dio Function() api = (() {
  final baseUrl = 'https://music.api.summerscar.me';
  // final baseUrl = 'https://flutterneteaseapi.herokuapp.com/';

  BaseOptions options = new BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: 10000,
    receiveTimeout: 10000,
  );

  final dio = Dio(options);
  dio.options.extra['withCredentials'] = true;

  var cookieJar = CookieJar();

  dio.interceptors.add(InterceptorsWrapper(onRequest: (Options options) async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('cookie');
    //Save cookies
    if (cookie != null) {
      Map cookiesMap = Map();
      List<Cookie> cookiesList;
      var cookies = cookie.split(';');
      // print(cookies);

      for (var cookie in cookies) {
        _setCookie(cookie, cookiesMap);
      }

      cookiesList = [
        new Cookie('MUSIC_U', cookiesMap['MUSIC_U']),
      ];

      cookieJar.saveFromResponse(Uri.parse(baseUrl), cookiesList);
    }
    return options; //continue
  }));

  if (!kIsWeb) {
    dio.interceptors.add(CookieManager(cookieJar));
  }

  return () => dio;
})();

void _setCookie(String rawCookie, Map cookiesMap) {
  if (rawCookie.length > 0) {
    var keyValue = rawCookie.split('=');
    if (keyValue.length == 2) {
      var key = keyValue[0].trim();
      var value = keyValue[1];

      // ignore keys that aren't cookies
      if (key == 'path' || key == 'expires') return;
      cookiesMap[key] = value;
    }
  }
}
