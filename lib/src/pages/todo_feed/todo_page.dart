import 'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/course/course_provider.dart';
import 'package:mcv_app/src/components/list/feed_item_search.dart';
import 'package:mcv_app/src/models/models.dart';
import 'package:mcv_app/src/pages/todo_feed/components/todo_list_view.dart';
import 'package:rxdart/streams.dart';

class TodoPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: CourseProvider.getBloc().courses,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            var courses = snapshot.data;
            var latests = CombineLatestStream(courses.map((course) => CourseProvider.getBloc().getCourseController(course.cvCid).assignments).toList(),
            (List<List<AssignmentItem>> listOfList) {
              var combinedList = List<AssignmentItem>();
              listOfList.forEach((list) {
                combinedList.addAll(list.where((item) {
                  var now = DateTime.now();
                  return DateTime.fromMillisecondsSinceEpoch(item.duetime*1000).difference(now) > Duration(days: -7); // Allow some over-due items
                }));
              });
              combinedList.sort((a, b) => a.duetime - b.duetime);
              return combinedList;
            });
            return StreamBuilder<List<AssignmentItem>>(
              stream: latests,
              builder: (context, snapshot) => TodoListView(snapshot.data ?? [])
            );
          default:
            return Text("Loading Courses List ...");
        }
      },
    );
  }


}