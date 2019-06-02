import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {

  final IconData icon;
  final String text;
  
  TabItem(this.icon, this.text);

   @override 
   Widget build(BuildContext context) {
     return Container(
        height: 48,
        child: Column(
          children: <Widget>[
            Icon(icon,
              color: Theme.of(context).textTheme.body1.color,
            ),
            Text(text, 
              style: Theme.of(context).textTheme.body1
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        )
      ); 
   }
}