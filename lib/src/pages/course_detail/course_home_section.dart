import "package:flutter/material.dart";
import 'package:mcv_app/src/components/list/feed_item_big.dart';
import "../../models/item.dart";
import "dart:async";

class CourseHomeSection extends StatefulWidget {
  final Stream<List<Item>> items;
  final bool forceExpanded;
  final String header; // enum: announcement, assignment, material 
  CourseHomeSection(this.header, this.items, {this.forceExpanded = false});
  @override _CourseHomeSectionState createState() => _CourseHomeSectionState();
}

class _CourseHomeSectionState extends State<CourseHomeSection> with AutomaticKeepAliveClientMixin {

  bool expanded;

  bool get isExpanded => expanded || widget.forceExpanded;

  @override
  void initState() {
    super.initState();
    print("build CourseHomeSection");
    expanded = false;
  }

  List<Widget> _mapItemToList(Iterable<Item> items) {
    var selectedItems = items.take(isExpanded ? 99 : 2);
    var resultList = <Widget>[];
    resultList.addAll(selectedItems.map((item) => FeedItemList(item: item)));
    if (selectedItems.length < items.length)
      resultList.add(
        Container(
          color: Color.fromARGB(255, 230, 230, 230),
          child: Text("${items.length - selectedItems.length} more item(s)", 
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        )
      );
    return resultList;
  }

  @override 
  Widget build(BuildContext context) {
    return StreamBuilder<List<Item>>(
      stream: widget.items,
      builder: (context, AsyncSnapshot<List<Item>> snapshot) {
        if (snapshot.hasError)
          return Icon(Icons.error);
        switch (snapshot.connectionState) {
          case ConnectionState.done:
          case ConnectionState.active:
            var items = snapshot.data..sort((a, b) => b.changed - a.changed); // sort descendingr
            var children = List<Widget>()
            ..add(
              GestureDetector(
                onTap: () {
                  if (!widget.forceExpanded)
                    setState(() {
                      expanded = !expanded;
                    });
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[ // Header
                        Icon(Icons.notifications),
                        Text(widget.header),
                        Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                      ]
                    ),
                  ),
                ),
              )
            )
            ..addAll(_mapItemToList(items)); 
            return Column(children: children);
          default:
            return Column(
              children: <Widget>[
                Text("Connection State = ${snapshot.connectionState}"),
                Container(width: 64, height: 64, child: CircularProgressIndicator()),
              ],
            ); 
        }
      }
    );
  }

  @override
  bool get wantKeepAlive => true;
}