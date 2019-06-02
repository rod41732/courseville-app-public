import 'package:flutter/material.dart';

class ListEntryBase extends StatelessWidget {
  final Widget body;
  final Widget icon;
  final Widget action;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;
  final Color color;
  const ListEntryBase({Key key, @required this.body, @required this.icon, this.action, this.onPressed, @required this.color, this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.all(2.0),
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width- 64 - 28,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(child: icon, width: 64,),
                      Container(
                        width: MediaQuery.of(context).size.width - 72 - 64 - 28,
                        child: body,
                      )
                    ]
                  ),
                ),
              Container(child: action, width: 64,)
            ],
          ),
        ),
      )
    );
  }
}