import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mcv_app/src/models/course.dart';
import 'package:mcv_app/src/pages/course_detail.dart';
import "./list_entry_base.dart";

class CourseItemList extends StatelessWidget {
  final Course course;
  CourseItemList({Key key, this.course}) : 
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListEntryBase(
      color: Color.fromARGB(255, 255, 255, 168),
      onPressed: () {
        Navigator.of(context).pushNamed("/course",
          arguments: CourseDetailArgs(courseID: course.cvCid, initialPage: 0)
        );
      },
      icon: CachedNetworkImage(imageUrl: course.icon, width: 64, height: 64,),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(course.name, style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 1.2), softWrap: true, maxLines: 1, overflow: TextOverflow.ellipsis,),
          Text("${course.courseNo} : SEC ${course.section}, YEAR ${course.year}/${course.semester}", style: Theme.of(context).textTheme.caption, maxLines: 1),
        ]
      ),
    );
  }
}