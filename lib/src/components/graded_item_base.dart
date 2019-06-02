import "package:flutter/material.dart";
import "../models/graded_item.dart";

class GradedItemWidgetBase extends StatelessWidget {
  final GradedItem _gradedItem;
  GradedItemWidgetBase(this._gradedItem);

  @override
  Widget build(BuildContext context){
    return Card(
      margin: EdgeInsets.only(left: 2, top: 2),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(_gradedItem.title, style: Theme.of(context).textTheme.title,),
                Row(children: <Widget>[
                  Text("??", style: Theme.of(context).textTheme.title,),
                  Text("/ ${_gradedItem.rawTotal}")
                ]),
              ],
            ),
            Container(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                children: _gradedItem.children.map((subItem) {
                  return GradedItemWidgetBase(subItem);
                }).toList(),
              ),
            )
          ],
        ),
      )
    );
  }
}