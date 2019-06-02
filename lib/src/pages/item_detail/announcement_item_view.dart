import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import "package:flutter/material.dart";
import 'package:mcv_app/src/components/html_render.dart';
import 'package:mcv_app/src/pages/item_detail/course_header.dart';
import "../../models/announcement_item.dart";
import "../../models/course.dart";
import "../../bloc/course/course_provider.dart";
import "package:flutter_html/flutter_html.dart";
import 'package:flutter_html/html_parser.dart';
import "package:url_launcher/url_launcher.dart";
class AnnouncementItemView extends StatelessWidget {
  final AnnouncementItem item;
  AnnouncementItemView(this.item);

  @override 
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: <Widget>[ 
        StreamBuilder<Course>(
          stream: CourseProvider.getBloc().getCourseController(item.courseID).info,
          builder: (BuildContext context, AsyncSnapshot<Course> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
              case ConnectionState.active:
                var course = snapshot.data;
                return CourseHeader(course: course, item: item);
                break;
              default:
                return Text("Loading course info");
            }
          },
        ),
        FutureBuilder(
          future: Future.delayed(Duration(milliseconds: 200), () => null),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Text(item.title, 
                          style: Theme.of(context).textTheme.title.merge(
                            TextStyle(
                              decoration: TextDecoration.underline,  
                            )
                          )
                        ),
                        MyHTMLRender(htmlContent: item.content),
                      ],
                    ),
                  ),
                );
                break;
              default:
                return new Container(width: 0, height: 0);
            }
          },)
      ],
    );
  }
}