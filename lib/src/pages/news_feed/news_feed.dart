import 'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/application/settings_manager.dart';
import 'package:mcv_app/src/models/item.dart';
import 'dart:core';
import 'package:mcv_app/src/pages/news_feed/components/course_group.dart';
import 'package:mcv_app/src/bloc/course/course_provider.dart';
import "dart:async";

import 'package:rxdart/rxdart.dart';


class NewsFeed extends StatefulWidget {

  @override 
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Future<void> _refresh() async {
    CourseProvider.getBloc().refresh.add(1);
    return ; // hacky way to make refresh indicator disappear
  }
  List<int> last = List();


  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: StreamBuilder<List<int>>(
        stream: CombineLatestStream.combine2(CourseProvider.getBloc().items, SettingsManager.instance.recentItemAge, (items, age) {
          
          var itemList = List<Item>.from(items); // copy
          itemList..removeWhere((item) => DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(item.changed*1000)) > Duration(days: age))
              ..sort((Item a, Item b) => b.changed - a.changed); //sort descending
          Set<int> courses = Set();
          itemList.forEach((item) {
            courses.add(item.courseID);
          });
          return courses.toList();
        }),
        // }).distinctUnique(equals: (l1, l2) => l1.toSet().difference(l2.toSet()).isEmpty),
        builder: (context, AsyncSnapshot<List<int>> snapshot) {
          if (snapshot.data != null) last = snapshot.data;
          var list  = (snapshot.data ?? last);
          return ListView(
            children: List<Widget>.generate(list.length, (idx) => CourseGroupWidget(courseID: list[idx])),
          );
        },
      ),
    );
  } 
}