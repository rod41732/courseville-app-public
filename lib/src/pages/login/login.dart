import "dart:async";
import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter/services.dart" show PlatformException;
import 'package:mcv_app/src/pages/login/dots.dart';
import "package:uni_links/uni_links.dart";
import "package:url_launcher/url_launcher.dart";
import "../../bloc/course/course_provider.dart";
import "../../bloc/api.dart" as api;
import "../../bloc/application/application_db.dart";

class LoginPage extends StatefulWidget {

  LoginPage({Key key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {

  StreamSubscription<String> _sub;
  TabController _tabController;
  TextEditingController ctrl = TextEditingController();

  @override void dispose() {
    super.dispose();
    _sub.cancel();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    initUniLinks();
  }

  Future<Null> handleRedirect() async {
    String token = await ApplicationDB.instance.get("token");
    if (token != null) Navigator.of(context).pushNamed("/home");
  }

  Future<Null> _handleLink(String url) async{
    int idx = url.lastIndexOf("code=");
    String code = url.substring(idx+5);
    var resp = await api.getApiToken(code);
    if (resp.statusCode == 200) {
      String token = json.decode(resp.body)["access_token"];
      api.myToken = token;
      await ApplicationDB.instance.set("token", token);
      await CourseProvider.delete();
      Navigator.of(context).pushReplacementNamed("/home");
      CourseProvider.getBloc().getCourses(); // retrigger 
    }

  }
  Future<Null> initUniLinks() async {
    print("Init UNI");
    String token = await ApplicationDB.instance.get("token");
    print(token);
    if ((token?.length ?? 0) > 10) {
      api.myToken = token;
      Navigator.of(context).pushReplacementNamed("/home");
      print("welcome\n");
    }
    try {
      _sub = getLinksStream().listen((String link) {
          if (link != null) _handleLink(link);
          else print("Link is null");
        },
        onError: (err) {
          print("Error listening to link $err");
        },
        onDone: () {
          print("Stream is done");
        },
        cancelOnError: false,
      );
      print("Listened to UNI LINKS");
      Uri initialURI = await getInitialUri();
      if (initialURI != null) {
        _handleLink(initialURI.toString());
      }
    } on PlatformException {
      print("Platform error");
    }
    //

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).accentColor,
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Image.asset("images/cv-logo.png", width: MediaQuery.of(context).size.width*0.8,),
                    Text("Welcome to \nmyCourseVille App", 
                      style: Theme.of(context).accentTextTheme.title.apply(
                        fontSizeFactor: 1.8,
                        fontWeightDelta: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text("Register", style: Theme.of(context).accentTextTheme.display2),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                        child: Text("If you haven't registered the myCourseville Platform account, please go to"+
                        "'Account' page of myCourseVille and register",
                        style: Theme.of(context).textTheme.title.apply(color: Colors.white),
                        textAlign: TextAlign.center,),
                      ),
                      RaisedButton(
                        child: Text("HOW TO DO THAT ?"),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: Text("How to create myCourseVille platform account", ),
                                contentPadding: EdgeInsets.all(16),
                                children: <Widget>[
                                  Text("1. Go to mycourseville.com",
                                    style: Theme.of(context).textTheme.body1.apply(fontSizeFactor: 1.2)
                                  ),
                                  Text("2. Click on the menu button (three stripes)"),
                                  Text("3. Press Account"),
                                  Text("4. Scroll down to 'MyCourseVille Platform Account' section"),
                                  Text("5. Enter your desired username and password."),
                                  Text("6. Press 'Save/Reset username/password'"),
                                ],
                              );
                            }
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Login", style: Theme.of(context).accentTextTheme.display2),
                    Text("Login with your myCourseVille platform account.", 
                      style: Theme.of(context).accentTextTheme.body1.apply(
                        fontSizeFactor: 1.2 
                      ),
                      textAlign: TextAlign.center,
                    ),
                    RaisedButton(
                      child: Text("LOGIN"),
                      onPressed: () async {
                          var token = await ApplicationDB.instance.get("token");
                          if ((token?.length ?? 0) > 10) {
                            api.myToken = token;
                            await CourseProvider.delete();
                            Navigator.of(context).pushReplacementNamed("/home");
                          } else {
                            await launch(
                                "https://mycourseville.com/api/oauth/authorize?client_id=VAH7tjZiqsWvGxsQ48QXgZWqxHAZMyuECbG3CUsA&redirect_uri=https%3A%2F%2Fcourseville-app.firebaseapp.com%2Foauth%2Fcallback&response_type=code");
                          }
                      },
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              height: 32,
              bottom: 48,
              child: DotIndicator(controller: _tabController,),
            )
          ]
        ),
      ),
    );
  }
}