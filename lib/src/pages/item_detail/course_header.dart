import "package:flutter/material.dart";
import 'package:mcv_app/src/pages/course_detail.dart';
import "../../models/models.dart";
import "package:cached_network_image/cached_network_image.dart";

class CourseHeader extends StatelessWidget {
  const CourseHeader({
    Key key,
    @required this.course,
    @required this.item,
  }) : super(key: key);

  final Course course;
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                Text("On " + DateTime.fromMillisecondsSinceEpoch(item.changed*1000).toIso8601String())
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () {
            Navigator.of(context).pushNamed("/course", arguments: CourseDetailArgs(courseID: course.cvCid));
          },
        )
      ],
    );
  }
}