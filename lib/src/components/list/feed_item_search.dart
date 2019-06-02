import 'package:flutter/material.dart';
import 'package:mcv_app/src/components/list/common_actions.dart';
import 'package:mcv_app/src/models/item.dart';
import 'package:mcv_app/src/pages/item_detail.dart';
import "./list_entry_base.dart";
import 'util.dart';

class FeedItemListSearch extends StatelessWidget {
  final String courseName;
  final String itemTitle;
  final Widget icon;
  final Item item; 
  final Widget _action;
  FeedItemListSearch({Key key, this.icon, this.courseName, @required this.item}) : 
  _action = actionWidgetFor(item),
  itemTitle = item.title,
  super(key: key);



  @override
  Widget build(BuildContext context) {
    return ListEntryBase(
      color: Colors.white,
      onLongPress: openItemMenu(context, item),
      onPressed: () {
        Navigator.of(context).pushNamed("/item", arguments: ItemDetailViewArgs(item));
      },
      icon: icon,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(itemTitle, style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 1.25), softWrap: true, maxLines: 1),
          Text("Course: $courseName", style: Theme.of(context).textTheme.caption, maxLines: 1),
        ],
     ),
     action: _action,
    );
  }
}