import 'dart:async';
import '../bloc/notification/notification_provider.dart';
import '../bloc/course/course_provider.dart';
import '../models/models.dart';
import 'package:background_fetch/background_fetch.dart';
import '../bloc/application/application_db.dart';
import '../bloc/api.dart' as api;
import 'dart:convert'; 
class BackgroundFetchController {

  static Future<int> fetchAllCourse() async {

    var courseBloc = CourseProvider.getBloc();
    if (api.myToken == null) {
      var token = await ApplicationDB.instance.get("token");
      api.myToken = token;
    }
    List<Course> courses = (await courseBloc.getCourses());
    List<Course> filtered = courses.where((course) {
      switch (course.following) {
        case 1:
          return true;
        case 2:
          return false;
        default: // auto
          return int.parse(course.year) >= 2018; // TODO: change this logic
      }
    }).toList();
    print("fetched  ${filtered.length} of ALL ${courses.length} course(s)");
    filtered.forEach((course) async {
      // get new items into list
      List<AssignmentItem> newAssignments = List(), updatedAssignments = List();
      List<MaterialItem> newMaterials = List(), updatedMaterials = List();
      List<AnnouncementItem> newAnnouncements = List(), updatedAnnouncements = List();
      var assignmentRequest = courseBloc.fetchCourseAssignments(course.cvCid, newItems: newAssignments, updatedItems: updatedAssignments, unCached: true); 
      var announcementRequest = courseBloc.fetchCourseAnnouncements(course.cvCid, newItems: newAnnouncements, updatedItems: updatedAnnouncements, unCached: true);
      var materialRequest = courseBloc.fetchCourseMaterials(course.cvCid, newItems: newMaterials, updatedItems: updatedMaterials, unCached: true); 
      await Future.wait([
        assignmentRequest,
        announcementRequest,
        materialRequest,
      ]);
      // display notification about items
      if (newAssignments.length + updatedAssignments.length > 0) {
        NotificationProvider.instance.sendNotification("${course.name}: ${newAssignments.length + updatedAssignments.length}New Assignments", 
          "[${newAssignments.length} New] " + newAssignments.map((item) => item.title).join(" ") + 
          "// [${updatedAssignments.length} Updated]" + updatedAssignments.map((item) => item.title).join(" "),
          payload: json.encode({'type': 'Course', 'data': {'id': course.cvCid, 'page': 1}})
        );
      } 
      if (newAnnouncements.length + updatedAnnouncements.length > 0) {
        NotificationProvider.instance.sendNotification("${course.name}: ${newAnnouncements.length + updatedAnnouncements.length} New Announcements", 
        "[${newAnnouncements.length} New] " + newAnnouncements.map((item) => item.title).join(" ") + 
          "// [${updatedAnnouncements.length} Updated]" + updatedAnnouncements.map((item) => item.title).join(" "),
          payload: json.encode({'type': 'Course', 'data': {'id': course.cvCid, 'page': 2}})
        );
      }
      if (newMaterials.length + updatedMaterials.length > 0) {
        NotificationProvider.instance.sendNotification("${course.name}: ${newMaterials.length + updatedMaterials.length} New Materials", 
          "[${newMaterials.length} New] " + newMaterials.map((item) => item.title).join(" ") + 
          "[${updatedMaterials.length} Updated]" + updatedMaterials.map((item) => item.title).join(" "),
          payload: json.encode({'type': 'Course', 'data': {'id': course.cvCid, 'page': 3}})
        );
      } 
    });
    // sendDebugNotif("BG Fetch", "Fetched ${filtered.length} courses");
    BackgroundFetch.finish();
    return filtered.length;    
  }

  static void sendDebugNotif(String title, content) {
    // NotificationProvider.instance.sendNotification(title, content);
  }

} 