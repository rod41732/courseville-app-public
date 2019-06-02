import 'package:cached_network_image/cached_network_image.dart';
import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';
import "package:flutter_html/flutter_html.dart";
import 'package:photo_view/photo_view.dart';

bool isUrl(String str) {
  return str.contains(
  	RegExp(r"\b((http|https):\/\/?)[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/?))")
  );
}

class MyHTMLRender extends StatelessWidget {
  
  final String htmlContent;

  const MyHTMLRender({Key key, this.htmlContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     return GestureDetector(
        child: Html(
          customRender: (node, children) {
            if (node.attributes?.containsKey("src") ?? false) { // image
              String url = node.attributes["src"];
              Uri uri = Uri.parse(url);
              if (uri.host == "" ) 
                url = "https://www.mycourseville.com" + url;
              return CachedNetworkImage(
                imageUrl: url,
                imageBuilder: (context, provider) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed("/photo", arguments: provider);
                    },
                    child: Image(
                      image: provider,
                    ),
                  );
                }, 
                placeholder: (ctx, url) => CircularProgressIndicator(),
                errorWidget: (ctx, str, obj) => Column(children: <Widget>[
                  Text("error loading : $str => $obj"),
                  Icon(Icons.error)  
                ],),);
            }
            return null;
          },  
          data: htmlContent ?? "<<p>No instruction provided</p>",
          padding: EdgeInsets.all(16),
          onLinkTap: (String url) async {
            if (Uri.parse(url).host == "") {
              url = "https://www.mycourseville.com" + url;
            }
            if (await canLaunch(url)) await launch(url);
            else Scaffold.of(context).showSnackBar(new SnackBar(content: Text("Can't launch url")));
          },
      ),
    );
  }
}