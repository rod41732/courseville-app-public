
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/course/course_provider.dart';
import 'package:mcv_app/src/models/models.dart';
import 'package:url_launcher/url_launcher.dart';

Widget actionWidgetFor(Item item) {
  switch (item.runtimeType) {
    case AnnouncementItem:
      return Builder(
        builder: (context) => IconButton(
          onPressed: () {
            CourseProvider.getBloc().markItemAsDone(item.type, item.itemid);
            Scaffold.of(context).showSnackBar(SnackBar(content: Text("Mark as Done !"),));
          },
          icon: Icon(Icons.done),
        ),
      );
    case MaterialItem:
      return Builder(
        builder: (context) =>  IconButton(
          onPressed: () async {
            MaterialItem mat = item as MaterialItem;
            if (await canLaunch(mat.filepath)) {
              await launch(mat.filepath);
            } else {
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Couldn't lauch url: ${mat.filepath}"),));
            }
          },
          icon: Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_downward),
          ),
        )
    );
    case AssignmentItem:
      /* 
      const MONTH_NAMES = ['', 'JAN', 'FEB', 'MAR', "APR", 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      var item2 = item as AssignmentItem;
      if (item2.duedate == null) return Container(width: 0, height: 0);
      var parts = item2.duedate.split("-").map(int.parse).toList();
      var month = MONTH_NAMES[parts[1]], day = parts[2]; 
      return Container(
        width: 48, 
        height: 48, 
        color: Colors.blueAccent,
        child: 
          Column(
            children: <Widget>[
              Text(month),
              Text(day.toString()), 
            ],
          ),
        );
      */
      var item2 = item as AssignmentItem;
      String unit = "---";
      String numbers = "---";
      Color color = Colors.grey;
      
      if (item2.duetime != null)  {
        var diff = DateTime.fromMillisecondsSinceEpoch(item2.duetime*1000).difference(DateTime.now());
        if (diff.inDays != 0) {
          unit = "DAY";
          int days = diff.inDays;
          numbers = days.toString();
          if (days >= 7) {
            color = Colors.green;
          } else if (days >= 3) {
            color = Colors.yellow;
          } else if (days >= 0) {
            color = Colors.orange;
          } else {
            color = Colors.red;
          }
        } else if (diff.inHours != 0) {
          unit = "HRS";
          numbers = diff.inHours.toString();
          color = Colors.red;
        } else {
          unit = "HRS";
          numbers = (diff.inMinutes < 0) ? '< -1' : "< 1";
          color = Colors.red;
        }
      }
      return Container(
        width: 32, 
        height: 48, 
        color: color,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(numbers),
            Text(unit), 
          ],
        ),
      );

    default:
      return Container(width: 0, height: 0);
  }
}  

String contentOf(Item item) {
  if (item is AssignmentItem) {
    return item.instruction;
  } 
  if (item is AnnouncementItem) {
    return item.content;
  }
  if (item is MaterialItem) {
    return item.description;
  }
  return "...";
}

Widget iconOf(Item item) {
  if (item is AssignmentItem)
    return Icon(Icons.assignment, size: 48);
  if (item is AnnouncementItem)
    return Icon(Icons.announcement, size: 48);
  if (item is MaterialItem)
    return CachedNetworkImage(imageUrl: item.thumbnail, width: 48, height: 48,);
  return Icon(Icons.build, size: 48);
}