import 'dart:async';

import 'package:flutter/services.dart';

class Auth0 {
  static const MethodChannel _channel = const MethodChannel('auth0');

  static Future<bool> login(String audience, {String scheme = "https"}) async {
    print("Logging in with audience : $audience");
    final Map<String, dynamic> params = {
      "audience": audience,
      "scheme": scheme
    };
    final res = await _channel.invokeMethod('login', params);
    return res;
  }

  static Future<bool> logout() async {
    final res = await _channel.invokeMethod('logout');
    return res;
  }

  static Future<String> get accessToken async {
    final res = await _channel.invokeMethod("getToken");
    return res;
  }

  static Future<bool> get isLoggedIn async {
    final res = await _channel.invokeMethod("isLoggedIn");
    return res;
  }
}
