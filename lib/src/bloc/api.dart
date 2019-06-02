import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

String myToken;
const APIBase = "https://mycourseville.com/api/v1/public/";

Future<Map<String, dynamic>> getCourses() async {
  print("get courses");
  if (myToken == null) {
    throw Exception("API Request Error: Token is null, please set token");
  }
  return http.get("$APIBase/get/user/courses?detail=1", headers: {"Authorization": "Bearer $myToken"})
      .then((resp) {
    print("DATA = ${resp.body}");
    return json.decode(resp.body);
  });
}

Future<http.Response> getApiToken(String code) async {
  Map<String, String> body = {
    "code": code,
  };
  return await http.post("https://us-central1-courseville-app.cloudfunctions.net/getToken",
      body: body);
}

Future<Map<String, dynamic>> getCourseData(int courseID) async {
  print("get course info $courseID");
  if (myToken == null) {
    throw Exception("API Request Error: Token is null, please set token");
  }
  return http.get("$APIBase/get/course/info?cv_cid=$courseID", headers: {"Authorization": "Bearer $myToken"})
  .then((resp) {
    print("DATA = ${resp.body}");
    return json.decode(resp.body)['data'];
  });
}

Future<Map<String, dynamic>> getCourseItems(int courseID, String itemType, int detailed) async {
  print("get items type=$itemType of $courseID");
  if (myToken == null) {
    throw Exception("API Request Error: Token is null, please set token");
  }
  return http.get("$APIBase/get/course/$itemType?cv_cid=$courseID&detail=$detailed", headers: {"Authorization": "Bearer $myToken"})
  .then((resp) {
    print("Response $itemType $courseID Length = ${json.decode(resp.body)['data'].length}");
    return json.decode(resp.body);
  });
}

Future<Map<String, dynamic>> getUserInfo() async {
  if (myToken == null) {
    throw Exception("API Request Error: Token is null, please set token");
  }
  print("[API] Get User Info");
  var resp = await http.get(
      "$APIBase/get/user/info", headers: {"Authorization": "Bearer $myToken"});
  return json.decode(resp.body);
}