import "package:flutter/material.dart";
import "../models/course.dart";
import "../components/course_item.dart";
import '../bloc/course/course_provider.dart';
import 'dart:async';
class CoursesPage extends StatefulWidget {

  CoursesPage();
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  
  Future<void> _refresh() async {
    var bloc = CourseProvider.getBloc();
    var courses = await bloc.getCourses(refresh: true);
    courses.forEach((course) {
      // to refresh all course
      var courseID = course.cvCid;
      bloc.getCourseController(courseID).getCourseInfo();
      bloc.getCourseController(courseID).getAnnouncements(offline: true);
      bloc.getCourseController(courseID).getAssignments(offline: true);
      bloc.getCourseController(courseID).getMaterials(offline: true);
    });
  }

  @override build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: StreamBuilder<List<Course>>(
        stream: CourseProvider.getBloc().courses,
        builder: (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done: 
            case ConnectionState.active: 
              if (snapshot.hasError) {
                print(snapshot.error);
                return Text("Error loading ${snapshot.error}");
              }
              return _build(context, snapshot.data);
            default: 
              return Text("Loading Courses...");
          }
        }),
    );
  }

  Widget _build(BuildContext context, List<Course> coursesData) {
    // sorts desending by year -> semester -> courseNo
    var columns = MediaQuery.of(context).size.width~/128;
    coursesData.sort((a, b) => ("${b.year}/${b.semester}/${b.courseNo}").compareTo(("${a.year}/${a.semester}/${a.courseNo}"))); 
    return GridView.count(
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      crossAxisCount: columns,
      childAspectRatio: (MediaQuery.of(context).size.width/columns)/192,
      children: List<Widget>.from(
        coursesData.map((course) => CourseItem(course))
      )
    );
  }
}