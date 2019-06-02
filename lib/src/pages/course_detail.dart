import "package:flutter/material.dart";
import 'package:mcv_app/src/pages/course_detail/couse_info.dart';
import '../bloc/course/course_provider.dart';
import '../components/tab_item.dart';
import "../models/course.dart";
import "../pages/course_detail/course_home.dart";
import "../pages/course_detail/course_score.dart";
import "../pages/course_detail/course_home_section.dart";
import "dart:async";


class CourseDetailArgs {
  int courseID;
  int initialPage;

  CourseDetailArgs({this.courseID, this.initialPage = 0});
}


class CourseDetail extends StatefulWidget {
  final int courseID;
  final int initialpage;

  CourseDetail(this.courseID, this.initialpage, {Key key}) : super(key: key);

  @override State<StatefulWidget> createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> with SingleTickerProviderStateMixin {

  int courseID;
  TabController _tabController;
  static const List<String> options = ["Default", "On", "Off"];
  static const List<IconData> icons = [Icons.notifications_none, Icons.notifications_active, Icons.notifications_off];

  @override
  void initState() {
    super.initState();
    courseID = widget.courseID;
    _tabController = TabController(length: 6, initialIndex: widget.initialpage, vsync: this);
  }

  void _debugDeleteAllData() {
    var db =CourseProvider.getBloc().courseDB.db;
    Future.wait([
      db.update("Course", {'lastAssignment': 0, 'lastMaterial': 0, 'lastAnnouncement': 0},
        where: "cv_cid = ? ",
        whereArgs: [courseID]
      ),
      CourseProvider.getBloc().getCourseInfo(courseID), // hacky way to refresh the data
      db.delete("Assignment", where: "cv_cid = ?", whereArgs: [courseID]),
      db.delete("Announcement", where: "cv_cid = ?", whereArgs: [courseID]),
      db.delete("Material", where: "cv_cid = ?", whereArgs: [courseID]),
    ]);
  }

  void _debugUnreadAll(){
    var db = CourseProvider.getBloc().courseDB.db;
    db.update("Material", {"read_flag": 0},
      where: "cv_cid = ?",
      whereArgs: [courseID]
    );
    db.update("Announcement", {"read_flag": 0},
      where: "cv_cid = ?",
      whereArgs: [courseID]
    );
    db.update("Assignment", {"read_flag": 0},
      where: "cv_cid = ?",
      whereArgs: [courseID]
    );
  }
  

  @override Widget build (BuildContext context) {
    var bloc = CourseProvider.getBloc();
    var courseController = bloc.getCourseController(courseID);
    bloc.getCourseController(courseID).getAnnouncements();
    bloc.getCourseController(courseID).getAssignments();
    bloc.getCourseController(courseID).getMaterials();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,  
        title: _buildCourseName(), 
        actions: <Widget>[
          // IconButton(icon: Text("del all"), onPressed: _debugDeleteAllData,),
          // IconButton(icon: Text("unread"), onPressed: _debugUnreadAll,),
          StreamBuilder<Course>(
            stream: CourseProvider.getBloc().getCourseController(courseID).info,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                case ConnectionState.done:
                  return PopupMenuButton<int>(
                    child: Icon(icons[snapshot.data.following]),
                    onSelected: (choice) {
                      CourseProvider.getBloc().getCourseController(courseID).setFollowing(choice);
                    },
                    itemBuilder: (context) {
                      List<PopupMenuItem<int>> choices = List()
                      ..add(
                        PopupMenuItem(
                          child: Text("Choose notification setting"),
                          enabled: false,
                        )
                      )
                      ..addAll(
                        List.generate(options.length, (idx) {
                          return PopupMenuItem(
                            child: Text(options[idx]),
                            value: idx,
                          );
                        })
                      );
                      return choices;
                    }
                  );
                default:
                  return Icon(Icons.battery_unknown);
              } 
            }
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          CourseHome(courseID),
          ListView(children: [CourseHomeSection("Assignments", bloc.getCourseController(courseID).assignments, forceExpanded: true,)]),
          ListView(children: [CourseHomeSection("Announcements", bloc.getCourseController(courseID).announcements, forceExpanded: true,)]),
          ListView(children: [CourseHomeSection("Materials", bloc.getCourseController(courseID).materials, forceExpanded: true,)]),
          CourseScore(courseID),
          CourseInfoPage(courseID: courseID,),
        ]
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: <Widget>[
          TabItem(Icons.home, "Home"),
          TabItem(Icons.assignment, "Homework"),
          TabItem(Icons.announcement, "Announce"),
          TabItem(Icons.picture_as_pdf, "Materials"),
          TabItem(Icons.list, "Scores"),
          TabItem(Icons.info, "About Course")
        ],
      ),
    );
  } 

  Widget _buildCourseName() {
    return StreamBuilder<Course>(
      stream: CourseProvider.getBloc().getCourseController(courseID).info,
      builder: (context, snapshot) {
        var course = snapshot.data;
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            return Text(course.name);
          default:
            return Text("Loading ...");
        }
      },
    );
  }
}

class CourseInfo {
}