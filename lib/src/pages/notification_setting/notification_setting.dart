import 'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/course/course_provider.dart';
import 'package:mcv_app/src/models/models.dart';
import "./components/course_entry.dart";
class NotificationSettings extends StatelessWidget {
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notitications"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) => SimpleDialog(
                  elevation: 5,
                  title: Text("How to set notifications ?", style: Theme.of(context).textTheme.title,),
                  contentPadding: EdgeInsets.all(8),
                  children: <Widget>[
                      Text("You can choose between three modes of notifications:\n" +
                      "- DEFAULT : fetch and notify change if this course is of current semester\n" +
                      "- ON : always fetch and notify changes in this course\n" +
                      "- OFF : never fetch and notify changes in this course" )
                  ],
                )
              );
            },
          )
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: CourseProvider.getBloc().courses,
        // initialData : [],
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done: 
              print(snapshot.data.length);
              return ListView(
                children: snapshot.data.map((course) => CourseSettingEntry(courseID: course.cvCid,)).toList()
              );
            default:
              return CircularProgressIndicator();
          }
        },
      ),
    );
  }

}