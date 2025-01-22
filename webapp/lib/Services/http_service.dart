import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';

class HttpService {
  static http.Client? client;

  static Future<Response> validatePassword(String password) async {
    client ??= http.Client();

    var requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
    };

    String uriString = kDebugMode
        ? 'http://localhost:3000/validate-password'
        : '/validate-password';

    var uri = Uri.parse(uriString);
    var response = await client!.post(uri,
        headers: requestHeaders, body: json.encode({'password': password}));
    return response;
  }

  static Future<Response> sendForm(String credentials, String body) async {
    client ??= http.Client();

    var requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Authorization': 'Basic $credentials'
    };

    String uriString =
        kDebugMode ? 'http://localhost:3000/send-email' : '/send-email';

    var uri = Uri.parse(uriString);
    var response = await client!.post(
      uri,
      headers: requestHeaders,
      body: body,
    );

    return response;
  }
}
