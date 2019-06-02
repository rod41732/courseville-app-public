import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mcv_app/src/components/dialog.dart';
import 'package:mcv_app/src/models/models.dart';
import '../models/course.dart';
import '../bloc/course/course_provider.dart';
import '../pages/course_detail.dart';
import "package:url_launcher/url_launcher.dart";
class CourseItem extends StatefulWidget {

  final Course _course;
  CourseItem(this._course);

  @override 
  _CourseItemState createState() => _CourseItemState();
}



class _CourseItemState extends State<CourseItem> {

  _CourseItemState() ;
  // bool hasFetched = false;
  @override Widget build(BuildContext context) {
    return StreamBuilder<Course>(
      stream: CourseProvider.getBloc().getCourseController(widget._course.cvCid).info,
      builder: (BuildContext context, AsyncSnapshot<Course> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.data == null) continue nodata;
            return _build(context, snapshot.data);
          nodata:
          case ConnectionState.none:
          case ConnectionState.waiting:
            if (snapshot.hasError) {
              return Text("Error loading ${snapshot.error}");
            }
            return _build(context, widget._course);
        }
      },
    );
  }

  void _markAllItemsAsRead() {
    CourseProvider.getBloc().markAllItemsAsRead(widget._course.cvCid);
    Scaffold.of(context).showSnackBar(new SnackBar(content: Text("Dismiss all items of ${widget._course.name}")));
    Navigator.of(context).pop();
  }

  void _debugDeleteAllData(int courseID) {
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

  Future<void> _showDismissDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyDialog(
          content: Text("Mark all items as read in course ${widget._course.name}"),
          title: Text("Dismiss all items ?"),
          // contentPadding: EdgeInsets.all(8),
          // titlePadding: EdgeInsets.all(8),
          actions: <Widget>[
            FlatButton(child: Text("NO"), onPressed: () {Navigator.of(context).pop();}),
            FlatButton(child: Text("YES", style: TextStyle(color: Colors.red)), onPressed: _markAllItemsAsRead)
          ],
        );
      }
    );
  }

  static const List<String> NAMES = ["Default", "On", "Off"];
  Future<void> _showNotificationDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return ChoiceDialog(
          initialVal: CourseProvider.getBloc().getCourseController(widget._course.cvCid).info.value.following,
          title: Text("Choose notification", style: Theme.of(context).textTheme.title.apply(fontSizeFactor: 1.2),),
          choiceBuilder: (choice) => Text(NAMES[choice],
            style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 1.1),
          ),
          choices: [0, 1, 2],
        );
      }
    )
    .then((choice) {
      if (choice == null) return;
      CourseProvider.getBloc().getCourseController(widget._course.cvCid)
      .setFollowing(choice);
    });
  }

  Widget _build(BuildContext context, Course course) {
    var controller = CourseProvider.getBloc().getCourseController(course.cvCid);
    return GestureDetector(  
      onTap: () {
        Navigator.of(context).pushNamed("/course", arguments: CourseDetailArgs(courseID: course.cvCid));
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => MyDialog(
            title: Container(width: 0, height: 0,),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BasicListEntry(
                  text: "Clear all notifications",
                  onPressed: () {
                    _showDismissDialog()
                    .then(Navigator.of(context).pop);
                  },
                ),
                BasicListEntry(
                  text: "Delete all Data",
                  onPressed: () {
                    _debugDeleteAllData(widget._course.cvCid);
                    Navigator.of(context).pop();
                  },
                ),
                BasicListEntry(
                  text: "Open in browser",
                  onPressed: () async {
                    var url = "https://www.mycourseville.com/?q=courseville/course/${widget._course.cvCid}";
                    if (await canLaunch(url)) {
                      launch(url)
                      .then(Navigator.of(context).pop);
                    }
                  },
                ),
                BasicListEntry(
                  text: "Notifications",
                  onPressed: _showNotificationDialog,
                ),
              ],
            ),
            actions: <Widget>[],
          )
        ); 
      },
      child: CourseItemGrid(course.courseNo, course.name, course.icon, [controller.newAssignmentCount, controller.newMaterialCount, controller.newAnnouncementCount])
    );   
  }
}

/// counts is array of [assignment, material, announcements]
class CourseItemGrid extends StatelessWidget {
  final String icon;
  final String courseNo;
  final String courseName;
  final List<Stream> counts;

  const CourseItemGrid(this.courseNo, this.courseName, this.icon, this.counts, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: Stack( // stack layout
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Column( // All displayed
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CachedNetworkImage(imageUrl: icon, height: 100,),
                Text(courseNo, style: Theme.of(context).textTheme.body2,
                textAlign: TextAlign.center,),
                Text(courseName, 
                  style: Theme.of(context).textTheme.body1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  )
              ]
            ),
          ),
          Positioned( 
            right: 8,
            top: 8,
            child: Row( // badges
              children: IterableZip([counts, [Colors.red, Colors.blue, Colors.yellow]])
              .map((pair) {
                var cnt = pair.first as Stream<int>;
                var color = pair.last as Color;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: color,
                  ),
                  padding: const EdgeInsets.all(0),
                  child: StreamBuilder<int>(
                    stream: cnt,
                    builder: (context, snapshot) {
                      return Text("${snapshot.data ?? '?'}", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1));
                    }
                  ),
                  constraints: BoxConstraints(
                    minHeight: 20,
                    minWidth: 20,
                  ),
                );
              }).toList()
            ),
          )
        ],
      )
    );
  }
}