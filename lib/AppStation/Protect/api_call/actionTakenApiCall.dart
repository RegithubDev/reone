import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';
import '../models/CProtect.dart';

class ActionTakenApiCall {
  String m_sessionId;
  String m_userId;

  // List<CProtect> m_actionList;
  late List<CProtect> listProtect = [];
  List<CProtect> itemsProtect = [];

  ActionTakenApiCall(this.m_sessionId, this.m_userId);

/*
  Future<Response> callActionTakenAPi() async {
    var dio = Dio();
    var response = await dio.get(
      GET_IRM_LIST,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          "Cookie": m_sessionId,
        },
      ),
      queryParameters: {"user": m_userId, "i_completed": "Resolved"},
    );
    return response;
  }
*/

  Future<http.Response> callActionTakenAPi() async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_IRM_LIST));
    request.body = json.encode({"user": m_userId, "i_completed": "Resolved"});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }


  Future<String> unitTestCallActionTakenAPi() async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_IRM_LIST));
    request.body = json.encode({"user": m_userId, "i_completed": "Resolved"});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode.toString();
  }
}
