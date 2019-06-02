import 'package:flutter/material.dart';
import 'package:mcv_app/src/components/dialog.dart';
import 'package:mcv_app/src/models/models.dart';
import 'package:mcv_app/src/pages/course_detail.dart';
import 'package:mcv_app/src/pages/item_detail.dart';
import "util.dart";
import "package:flutter/services.dart";
import 'package:url_launcher/url_launcher.dart';
typedef VoidCallback CallbackCreator(BuildContext ctx, Item item);

CallbackCreator openItemMenu = (BuildContext context, Item item) => () {
  showDialog(
    context: context,
    builder: (context) => MyDialog(
      title: Text("Actions", 
        style: Theme.of(context).textTheme.title.apply(fontSizeFactor: 1.1)
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          (Item item) {
            String text;
            switch (item.runtimeType) {
              case MaterialItem:
                text = "Download File";
                break;
              case AnnouncementItem:
                text = "??? <nothing to do>";
                break;
              case AssignmentItem:
                text = "Do assignment (already exist)";
                break;
              default: 
                text = "<Unknown action>";
            }
            return BasicListEntry(
              text: text,
              onPressed: () async {
                switch (item.runtimeType) {
                  case MaterialItem:
                    var url = (item as MaterialItem).filepath;
                    if (await canLaunch(url)) {
                      launch(url);
                    }
                    break;
                  case AnnouncementItem:
                    
                    break;
                  case AssignmentItem:
                    
                    break;
                  default: 
                    text = "<Unknown action>";
                }   
              },
            );
          } (item),
          BasicListEntry(
            text: "Open",
            onPressed: () {
              Navigator.of(context).pushNamed("/item", arguments: ItemDetailViewArgs(item))
              .then(Navigator.of(context).pop);
            },
          ),
          BasicListEntry(
            text: "View Parent Course",
            onPressed: () {
              Navigator.of(context).pushNamed("/course", arguments: CourseDetailArgs(courseID: item.courseID, initialPage: 0))
              .then(Navigator.of(context).pop);
            },
          ),
          BasicListEntry(
            text: "More ${item.type} from this course",
            onPressed: () {
              int type = 0;
              switch (item.runtimeType) {
                case AssignmentItem: type = 1; break;
                case AnnouncementItem: type = 2; break;
                case Material: type = 3; break;
              }
              Navigator.of(context).pushNamed("/course", arguments: CourseDetailArgs(courseID: item.courseID, initialPage: type))
              .then(Navigator.of(context).pop);
            }
          ),
          BasicListEntry(
            text: "Open in browser",
            onPressed: () async {
              if (await canLaunch(item.url)) {
                launch(item.url);
                Navigator.of(context).pop();
              }
            },
          ),
          BasicListEntry(
            text: "Copy link",
            onPressed: () {
              Clipboard.setData(ClipboardData(text: item.url));
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Copied to clipboard!"),
                  duration: Duration(milliseconds: 500),
                )
              );
            },
          ),
        ],
      ),
    ) 
  );
};