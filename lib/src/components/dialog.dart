import "package:flutter/material.dart";





typedef Widget WidgetBuilder(dynamic);

class ChoiceDialog extends StatefulWidget {
  
  final List<dynamic> choices;
  final Widget title;
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry contentPadding;
  final dynamic initialVal;
  WidgetBuilder choiceBuilder;

  // final Builder ;
  ChoiceDialog({Key key,
    this.choices,
    this.title,
    this.titlePadding = const EdgeInsets.fromLTRB(32, 16, 32, 16),
    this.contentPadding = const EdgeInsets.only(left: 16, right: 16),
    this.choiceBuilder,
    this.initialVal,
  }) : super(key: key) {
    if (choiceBuilder == null) {
      choiceBuilder = (choice) => Builder(
        builder: (context) {
          return Text("Choice ... $choice", style: Theme.of(context).textTheme.button.apply(fontSizeFactor: 1.2),);
        },
      );
    }
  }

  @override
  _ChoiceDialogState createState() => _ChoiceDialogState(initialVal);
}

class _ChoiceDialogState extends State<ChoiceDialog> {
  
  dynamic currentVal;
  
  _ChoiceDialogState(dynamic initialVal) {
    currentVal = initialVal;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      content: Column(
        mainAxisSize: MainAxisSize.min, // Need to set min !
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.choices.map((choice) { 
          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Radio(
                onChanged: (val) {
                  setState(() {
                    currentVal = val;
                  });
                },
                groupValue: currentVal,
                value: choice,
              ),
              widget.choiceBuilder(choice),
            ],
          );
        }).toList()
      )  ,
      actions: <Widget>[
        FlatButton(child: Text("OK"), textColor: Theme.of(context).accentColor, onPressed: () {
          Navigator.of(context).pop(currentVal);
        }),
        FlatButton(child: Text("CANCEL"), textColor: Colors.redAccent, onPressed: () {
          Navigator.of(context).pop(null);
        }),
      ],
    );
  }
}

class MyDialog extends StatefulWidget {
  
  final Widget title;
  final Widget content;
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry contentPadding;
  final List<Widget> actions;
  // final Builder ;
  MyDialog({Key key,
    this.title,
    this.titlePadding = const EdgeInsets.fromLTRB(32, 16, 32, 16),
    this.contentPadding = const EdgeInsets.only(left: 16, right: 16),
    this.content, this.actions,
  }) : super(key: key);

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      content: widget.content,
      actions: widget.actions ?? <Widget>[
        FlatButton(child: Text("OK"), textColor: Theme.of(context).accentColor, onPressed: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}

class BasicListEntry extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const BasicListEntry({Key key, @required this.text, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text, style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 1.1)),
          ),
        ],
      ),
    );
  }
}