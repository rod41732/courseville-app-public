import "package:flutter/material.dart";
import 'package:mcv_app/src/pages/item_detail/assignment_item_view.dart';
import 'package:mcv_app/src/pages/item_detail/material_item_view.dart';
import '../pages/item_detail/announcement_item_view.dart';
import "../models/models.dart";
import "package:url_launcher/url_launcher.dart";
import 'package:flutter/services.dart';
// this class delegate build to specialized class for item type

class ItemDetailViewArgs {
  Item item;

  ItemDetailViewArgs(this.item);
}

class ItemDetailView extends StatelessWidget {
  final Item item;

  const ItemDetailView({Key key, this.item}) : super(key: key);


  @override 
  Widget build(BuildContext context) {
    Widget body;
    if (item is AnnouncementItem) body = AnnouncementItemView(item);
    else if (item is MaterialItem) body = MaterialItemView(item);
    else if (item is AssignmentItem) body = AssignmentItemView(item);
    else body = Text("Invalid Item type");
    String url = item.url;
    return Scaffold(
      appBar: AppBar(
        title: Text("Item detail"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: "Open in browser",
            onPressed: () {
              Navigator.of(context).pushNamed("/search");
            },
          ),
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.open_in_new),
                tooltip: "Open in browser", 
                onPressed: () async {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Can't open $url"),
                        action: SnackBarAction(
                          label: "Copy Url",
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: url,)
                            );
                          },
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            }
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.content_copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("Copied to clipboard"), duration: Duration(milliseconds: 500)),
                );
              },
            ),
          )
        ]),
      body: body,
      // floatingActionButton: _buildFAB(item, context),
    );
  }


  Widget _buildFAB(Item item, BuildContext context) {
    switch (item.runtimeType) {
      case MaterialItem:
        return FloatingActionButton(
          child: Icon(Icons.arrow_downward),
          onPressed: () async{ 
            var url = (item as MaterialItem).filepath;
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Can't launch $url"),
                  duration: Duration(milliseconds: 500),
                ),
              );
            }
          },
        );
      case AssignmentItem:
        return FloatingActionButton(
          child: Icon(Icons.arrow_downward),
          onPressed: () async{ 
            String url = item.url;
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Can't launch $url"),
                  duration: Duration(milliseconds: 500),
                ),
              );
            }
          },
        );
      case AnnouncementItem :
        return FloatingActionButton(
          child: Icon(Icons.arrow_downward),
          onPressed: () async {
          },
        );
      default: 
        return Container(width: 0, height: 0,);
    }
  }
}