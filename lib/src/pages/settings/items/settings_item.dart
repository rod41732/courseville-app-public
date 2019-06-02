import 'package:flutter/material.dart';


class SettingsItem extends StatelessWidget {
  final Widget primaryText;
  final Widget secondaryText;
  final Widget icon;
  final VoidCallback callback;

  const SettingsItem({Key key, this.primaryText, this.secondaryText, this.icon, @required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              icon != null ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.restore, size: 32,),
              ) : Container(width: 0, height: 0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width-64,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      primaryText,
                      secondaryText,
                    ]
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 2, color: Colors.grey)
        ],
      ),
    );
  }

}