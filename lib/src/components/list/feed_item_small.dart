import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/course/course_provider.dart';
import 'package:mcv_app/src/models/item.dart';
import 'package:mcv_app/src/models/models.dart';
import 'package:mcv_app/src/pages/item_detail.dart';
import "./list_entry_base.dart";
import 'util.dart';
import "common_actions.dart";
class FeedItemListSmall extends StatefulWidget {
  final String _title;
  final String _content;
  final Widget _icon;
  final Widget _action;
  final Item item;
  FeedItemListSmall({Key key, this.item}) :
    _title= item.title,
    _action= actionWidgetFor(item),
    _content= contentOf(item),
    _icon= iconOf(item),
    super(key: key);

  @override
  _FeedItemListSmallState createState() => _FeedItemListSmallState(highlight: item.readFlag == 0);
}

class _FeedItemListSmallState extends State<FeedItemListSmall> {

  bool highlight;
  _FeedItemListSmallState({@required this.highlight});


  @override
  Widget build(BuildContext context) {
    return ListEntryBase(
      onLongPress: openItemMenu(context, widget.item),
      color: highlight ? Color.fromARGB(255, 255, 183, 183) : Color.fromARGB(255, 245, 245, 245),
      onPressed: () {
        Navigator.of(context).pushNamed("/item", arguments: ItemDetailViewArgs(widget.item));
        if (highlight) {
          var item = widget.item;
          CourseProvider.getBloc().markItemAsRead(item.type, item.itemid);
          setState(() {
            highlight = false;
          });
          var controller = CourseProvider.getBloc().getCourseController(item.courseID);
          switch (item.runtimeType) {
            case AssignmentItem:
              controller.getAssignments(offline: true);
              break;
            case AnnouncementItem:
              controller.getAnnouncements(offline: true);
              break;
            case MaterialItem:
              controller.getMaterials(offline: true);
              break;
          }
        }
      },
      icon: widget._icon,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget._title, style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 1.2), softWrap: true, maxLines: 1),
          Text(widget._content, style: Theme.of(context).textTheme.caption, maxLines: 1),
        ],
      ),
      action: widget._action
    );
  }
}