import "package:flutter/material.dart";
import "../course_detail/course_home_section.dart";
import "../../bloc/course/course_provider.dart";
import 'dart:async';
class CourseHome extends StatelessWidget { // TODO: stateful = sort, filter etc
  final int courseID; 

  CourseHome(this.courseID);

  Future<void> _refresh() async {
    var bloc = CourseProvider.getBloc();
    bloc.getCourseController(courseID).getAnnouncements();
    bloc.getCourseController(courseID).getAssignments();
    bloc.getCourseController(courseID).getMaterials();
    return 0;
  }

  @override Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    var bloc = CourseProvider.getBloc();
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: ListView(
        children: <Widget>[
          CourseHomeSection("Latest Announcements", bloc.getCourseController(courseID).announcements),
          CourseHomeSection("Course Materials", bloc.getCourseController(courseID).materials),
          CourseHomeSection("Homeworks (Assignments)", bloc.getCourseController(courseID).assignments),
        ],
      ),
    );
  }
}
