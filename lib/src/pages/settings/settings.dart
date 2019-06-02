import 'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/application/settings_manager.dart';
import '../../components/dialog.dart';
import './items/settings_item.dart';
import "../../bloc/application/application_db.dart";
class SettingsPage extends StatelessWidget {
  
  SettingsPage();

  void _showDialog(BuildContext context, int initialChoice) {
    showDialog(
      context: context,
      builder: (context) {
        return ChoiceDialog(
          initialVal: initialChoice,
          choiceBuilder: (choice) => Text("$choice days", style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 1.1),),
          choices: [7, 15, 21, 30],
          title: Text("Choose Notification Range",
            style: Theme.of(context).textTheme.title.apply(fontSizeFactor: 1.2),
          ),
        );
      }
    )
    .then((choice) {
      if (choice != null) {
        SettingsManager.instance.recentItemAge.add(choice as int);
      }
    });
  }

  @override Widget build(BuildContext context) {
    var children = List<Widget>()
    ..add(
      SettingsItem(
        icon: Icon(Icons.restore, size: 32,),
        primaryText: Text("Feed Item Range",
          style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 1.2),
        ),
        secondaryText: StreamBuilder(
          stream: SettingsManager.instance.recentItemAge,
          builder: (context, snapshot) {
            return Text("---> ${snapshot.data} Day(s)",
              style: Theme.of(context).textTheme.caption.apply(fontSizeFactor: 1.2),
            );
          },
        ),
        callback: () {_showDialog(context, SettingsManager.instance.recentItemAge.value);},
      )
    )
    ..add(
      SettingsItem(
        icon: Icon(Icons.notifications , size: 32,),
        primaryText: Text("Configure Course Notification",
          style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 1.2),
        ),
        secondaryText: Text("Change whether you are subscribing to each course's notification",
          style: Theme.of(context).textTheme.caption.apply(fontSizeFactor: 1.2),
        ),
        callback: () {
          Navigator.of(context).pushNamed("/courseSettings");
        },
      )
    )
    ..add(
      RaisedButton(
        color: Colors.redAccent,
        child: Text("LOG OUT"),
        onPressed: () async {
          await ApplicationDB.instance.set("token", "");
          Navigator.of(context).pushReplacementNamed("/");
        },
      )
    );
    return ListView(
      children: children
    );
  }
}
