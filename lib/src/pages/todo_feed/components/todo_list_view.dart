import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mcv_app/src/components/list/feed_item_big.dart';
import 'package:mcv_app/src/models/assignments_item.dart';

class TodoListView extends StatelessWidget {
  final List<AssignmentItem> assignments;

  const TodoListView(this.assignments, {Key key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    var pending = assignments.where((item) => DateTime.fromMillisecondsSinceEpoch(item.duetime*1000).isAfter(now));
    var overdue = assignments.where((item) => DateTime.fromMillisecondsSinceEpoch(item.duetime*1000).isBefore(now));
    var listChildren = List<Widget>()
    ..add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Upcoming Item",
          style: Theme.of(context).textTheme.body1.apply(
            fontSizeFactor: 1.2,
          ),
        ),
      )
    )
    ..addAll(pending.map((item) => FeedItemList(item: item,)))
    ..add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Overdue Item",
          style: Theme.of(context).textTheme.body1.apply(
            fontSizeFactor: 1.2,
            color: Theme.of(context).errorColor,
          ),
        ),
      )
    )
    ..addAll(overdue.map((item) => FeedItemList(item: item,)));

    return ListView(
      children: listChildren,
    ); 
  }

}