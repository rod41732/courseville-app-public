import 'package:cached_network_image/cached_network_image.dart';
import  'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/course/course_provider.dart';
import 'package:mcv_app/src/models/models.dart';


class CourseSettingEntry extends StatelessWidget {
  final int courseID;

  const CourseSettingEntry({Key key, this.courseID}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var controller = CourseProvider.getBloc().getCourseController(courseID);
    return StreamBuilder<Course>(
      stream: controller.info,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
          var course = snapshot.data;
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CachedNetworkImage(imageUrl: course.icon, width: 64, height: 64,),
                Container(
                  width: MediaQuery.of(context).size.width-64-48*3,
                  child: Text(course.name)
                ),
                Row(
                  children: [0, 1, 2].map((val) {
                    return Radio(
                      groupValue: course.following,
                      value: val,
                      onChanged: controller.setFollowing,
                    );
                  }).toList(),
                )
              ],
            );
            break;
          default:
            return CircularProgressIndicator();
        }
      },
    );
  }
}