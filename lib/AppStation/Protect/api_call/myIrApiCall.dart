import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';
import '../models/CProtect.dart';

class MyIRApiCall {
  String m_sessionId;
  String m_userId;
  late List<CProtect> listProtect = [];
  List<CProtect> itemsProtect = [];

  MyIRApiCall(this.m_sessionId, this.m_userId);

  Future<http.Response> callMyIrAPi() async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_IRM_LIST));
    request.body = json.encode({"admin_incidents": m_userId});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  Future<String> unitTestCallMyIrAPi() async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_IRM_LIST));
    request.body = json.encode({"user": m_userId});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode.toString();
  }
}
