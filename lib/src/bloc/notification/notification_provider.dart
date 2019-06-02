import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter/material.dart";
import "dart:math";
import "dart:async";
import "dart:convert";
import "../../pages/course_detail.dart";
typedef void Handler(String payload); 

class NotificationProvider  {
  static NotificationProvider instance = NotificationProvider._internal(null);
  final FlutterLocalNotificationsPlugin _plugin = new FlutterLocalNotificationsPlugin();
  final Random _rng = new Random();
  BuildContext _context; // for reference when handling notif  
  
  factory NotificationProvider() {
    return instance;
  }

  static setContext(BuildContext flutterContext) {
    instance = NotificationProvider._internal(flutterContext);
  }

  NotificationProvider._internal(BuildContext flutterContext){
    var initSettingsAndroid = new AndroidInitializationSettings("cv_icon");
    var initSettingIos = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(initSettingsAndroid, initSettingIos);
    _plugin.initialize(initSettings,
    onSelectNotification: (String payload) {
      // This work even app is killed
      var data = json.decode(payload) as Map<String, dynamic>;
      if (data['type'] == "Course") {
        var courseID = data['data']['id'] as int;
        var initialPage = data['data']['page'] as int;
        Navigator.of(flutterContext).pushNamed('/course', arguments: CourseDetailArgs(courseID: courseID, initialPage: initialPage));
      }
    });
  }


  Future<void> sendNotification(String title, String body, {String payload, int id, NotificationDetails notificationDetails}) async {
    if (notificationDetails == null) {
      var androidPlatformSpecifics = new AndroidNotificationDetails('default', 'Default', 'Default Notification Channel.',
        importance: Importance.Max,
        priority: Priority.High,
      );
      var iOSPlatformSpecifics = new IOSNotificationDetails();
      notificationDetails = new NotificationDetails(androidPlatformSpecifics, iOSPlatformSpecifics);
    }
 
    _plugin.show(id ?? _rng.nextInt(1 << 30), title, body, notificationDetails, payload: payload ?? "{}");
  }
}