import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/course/course_provider.dart';
import 'package:mcv_app/src/models/course.dart';

class CourseInfoPage extends StatelessWidget {
  final int courseID;

  const CourseInfoPage({Key key, this.courseID}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Course>(
      stream: CourseProvider.getBloc().getCourseController(courseID).info,
      builder: (context, snapshot) {
        var course = snapshot.data;
        return ListView(
          children: <Widget>[
            CachedNetworkImage(imageUrl: course?.icon ?? "", height: 200,),
            Center(child: Text(course?.name ?? "Unknown", style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 2), maxLines: 2,)),
            InfoEntry(fieldName: "Course Number", fieldData: course?.courseNo ?? "######",),
            InfoEntry(fieldName: "Course ID", fieldData: course?.cvCid ?? "#####",),
            InfoEntry(fieldName: "Semester", fieldData: course?.semester ?? "?",),
            InfoEntry(fieldName: "Section", fieldData: course?.section ?? "?",),
            InfoEntry(fieldName: "Year", fieldData: course?.year ?? "?",),            
          ],
        );  
      }
    );
  }

}


class InfoEntry extends StatelessWidget {
  final String fieldName;
  final dynamic fieldData;

  const InfoEntry({Key key, this.fieldName, this.fieldData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.baseline,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(fieldName, style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.4),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$fieldData", style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 1.2),),
          ),
        ],
      ),
    );
  }

}