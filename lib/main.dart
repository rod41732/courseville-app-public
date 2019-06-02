import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcv_app/src/bloc/application/profile.dart';
import 'package:mcv_app/src/pages/course_detail.dart';
import 'package:mcv_app/src/pages/course_detail/couse_info.dart';
import 'package:mcv_app/src/pages/item_detail.dart';
import 'package:mcv_app/src/pages/notification_setting/notification_setting.dart';
import 'package:mcv_app/src/pages/profile/profile.dart';
import 'package:photo_view/photo_view.dart';
import 'src/components/tab_item.dart';
import 'package:mcv_app/src/pages/news_feed/news_feed.dart';

import 'src/pages/settings/settings.dart';
import 'src/pages/courses.dart';
import 'src/pages/login/login.dart';
import 'src/pages/search/search_page.dart';
import 'src/models/settings.dart';
import "package:rxdart/rxdart.dart";

import "src/bloc/notification/notification_provider.dart";
import "src/bloc/application/application_db.dart";
import "package:background_fetch/background_fetch.dart";
import 'src/background_task/background_fetch.dart';
import "package:mcv_app/src/bloc/api.dart" as api;
import 'dart:async';

import 'src/pages/todo_feed/todo_page.dart';
Future<void> headlessTask() async {
  int numCourses = await BackgroundFetchController.fetchAllCourse();
  BackgroundFetchController.sendDebugNotif("Headless BG Fetch Completed", "Fetched $numCourses course(s)");

}

Future<void> backgroundTask() async {
  int numCourses = await BackgroundFetchController.fetchAllCourse();
  BackgroundFetchController.sendDebugNotif("Background Fetch Completed", "Fetched $numCourses course(s)");
}

void main() {
  runApp(MyApp());
  BackgroundFetch.configure(BackgroundFetchConfig(
    minimumFetchInterval: 15,
    enableHeadless: true,
    stopOnTerminate: false,
    forceReload: false,
    startOnBoot: true,
  ), backgroundTask)
  .then((status) => print("Background Task Started $status"))
  .catchError(print);
  BackgroundFetch.registerHeadlessTask(headlessTask);
  // CourseProvider.getBloc().setNotificationListener((items) async {
  //   var course = await CourseProvider.getBloc().getCourseInfo(items.first.courseID);
  //   NotificationProvider.instance.sendDefaultNotification("New/Updated Items on ${course.name}", items.map((item) => item.title).join("\n"));
  // });
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MyCourseVille',
        theme: ThemeData.light(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case "/":
              return MaterialPageRoute(
                builder: (context) => LoginPage()
              );
            case "/home": 
              return MaterialPageRoute(
                builder: (context) => MyHomePage(title: 'MyCourseVille')
              );
            case "/search": 
              return MaterialPageRoute(
                builder: (context) => SearchPage()
              );
            case "/course": 
              CourseDetailArgs args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) => CourseDetail(args.courseID, args.initialPage)
              );
            case "/item":
              ItemDetailViewArgs args = settings.arguments;
              return MaterialPageRoute(
                builder: (context) => ItemDetailView(item: args.item,)
              );
            case "/courseSettings":
              return MaterialPageRoute(
                builder: (context) => NotificationSettings()
              );
            case "/photo": 
              ImageProvider provider = settings.arguments;
              return MaterialPageRoute(
                builder: (context) => PhotoView(
                  imageProvider: provider,
                )
              );
          }
        },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  BasicMessageChannel<String> channel = BasicMessageChannel<String>(
      "test", StringCodec());
 
  TabController _tabController;
  BehaviorSubject<int> _tabIndex = BehaviorSubject<int>()..add(0);

  @override void initState() {
    super.initState();
    _tabController = new TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      this._tabIndex.add(_tabController.index);
    });
    NotificationProvider.setContext(context);
  }

  @override
  Widget build(BuildContext context) {
    ProfileProvider.instance.getProfile();
    return Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: StreamBuilder<int>(
                stream: _tabIndex.stream,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return Text(<String>["Feed", "Todo", "Home", "Settings", "Account"][snapshot.data]);
                    default:
                      return Text("...");
                  }
                }
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/search");
                  },
                )
              ]
          ),
          body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                NewsFeed(),
                TodoPage(),
                CoursesPage(),
                SettingsPage(),
                ProfilePage(),
              ]
          ),
          bottomNavigationBar: TabBar(
            controller: _tabController,
            tabs: <Widget>[
              TabItem(Icons.list, "Feed"),
              TabItem(Icons.check_box, "Todo"),
              TabItem(Icons.home, "Home"),
              TabItem(Icons.settings, "Settings"),
              TabItem(Icons.account_circle, "Account"),
            ],
          ),
    );

  }

}
