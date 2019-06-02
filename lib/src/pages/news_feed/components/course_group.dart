import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/application/settings_manager.dart';
import 'package:mcv_app/src/components/list/feed_item_big.dart';
import 'package:mcv_app/src/components/list/feed_item_small.dart';

import "package:mcv_app/src/bloc/course/course_provider.dart";
import 'package:mcv_app/src/models/models.dart';
import 'package:mcv_app/src/pages/course_detail.dart';
import "package:rxdart/rxdart.dart";
import 'package:url_launcher/url_launcher.dart';

class CourseGroupWidget extends StatefulWidget {
  final int courseID;
  CourseGroupWidget({this.courseID})
    : super(key: ValueKey(courseID));

  @override
  State<CourseGroupWidget> createState() => _CourseGroupWidgetState();
}

class _CourseGroupWidgetState extends State<CourseGroupWidget> with AutomaticKeepAliveClientMixin {
  bool expanded = false;
  
  @override
  Widget build(BuildContext context) {
    print("CourseGroup ${widget.courseID}");
    var controller = CourseProvider.getBloc().getCourseController(widget.courseID);
    CombineLatestStream<dynamic, List<List<Item>>> stream = CombineLatestStream.combine3(controller.announcements,
     controller.assignments, controller.materials,
    (a, b, c) => <List<Item>>[a, b, c]);
    return StreamBuilder<int>( 
      stream: SettingsManager.instance.recentItemAge,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            var maxAge = snapshot.data;
            return StreamBuilder<List<List<Item>>>(
              stream: stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                  case ConnectionState.done: 
                  var items = snapshot.data.expand((x) => x).where((x) {
                    return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(x.changed*1000)) < Duration(days: maxAge);
                  }).toList();
                    if (!expanded)
                      return  _buildCollapsed(context, items);
                    return _buildExpand(context, items);
                    break;
                  default:
                    return Text("${widget.courseID} ${snapshot.connectionState.toString()}");
                }  
            });
          default:
            return Text("Wating for recentItemAge Setting");
        }
      }
    );
  }


  Widget _buildCollapsed(BuildContext context,  List<Item> items) {    
    var paddedChildren = List<Widget>();
    items.sort((a, b) => b.changed - a.changed);
    // combine list, sort descending by time
    paddedChildren.addAll(
      items.take(5).map((item) => FeedItemListSmall(item: item))
    );
    if (items.length > 5) {
      paddedChildren.add(
        Container(
          padding: EdgeInsets.all(8),
          color: Color.fromARGB(230, 230, 230, 230),
          child: Text("${items.length - 5} more items")
        )
      );
    }

    return Container(
      child: Column(
        children: <Widget>[
          _buildCourseHeader(widget.courseID),
          Container(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              children: paddedChildren,
            ),
          )
        ]
      ),

    );
  }

  Widget _buildExpand(BuildContext context,  List<Item> items) {
    var children = List<Widget>();
    children.add(_buildCourseHeader(widget.courseID)); 

    items.sort((a, b) => b.changed - a.changed); // sort descending by time
    children.addAll(
      items.map((item) => FeedItemList(item: item))
    );
    return Column(children: children);
  }

  Widget _buildCourseHeader(int courseID) {
    return StreamBuilder<Course>(
      stream: CourseProvider.getBloc().getCourseController(courseID).info,
      builder: (context, snapshot) {
        switch (snapshot.connectionState){
          case ConnectionState.active:
          case ConnectionState.done:
            var course = snapshot.data;
            return GestureDetector(
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              child: Card(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CachedNetworkImage(imageUrl: course.icon, width: 48, height: 48),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.6,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(course.name, style: Theme.of(context).textTheme.title),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: () {
                        Navigator.of(context).pushNamed("/course", arguments: CourseDetailArgs(courseID: courseID, initialPage: 0));
                      },
                    )
                  ],
                ),
              ),
            );
          default:
            return Text("Loading");
        }
      }
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class CourseHeader extends StatelessWidget {
  const CourseHeader({
    Key key,
    @required this.course,
  }) : super(key: key);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CachedNetworkImage(imageUrl: course.icon),
            Text(course.name),
            FlatButton(
              child: Row(
                children: <Widget>[
                  Text("Go to course"),
                  Icon(Icons.chevron_right),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pushNamed("/course", arguments: CourseDetailArgs(courseID: course.cvCid));
              },
            )
          ],
        ),
      ),
    );
  }
}
