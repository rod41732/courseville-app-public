import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mcv_app/src/components/list/course_item_list.dart';
import 'package:mcv_app/src/components/list/feed_item_search.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../../models/models.dart';
import "../../bloc/course/course_provider.dart";

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

typedef void VoidFunc();

class _SearchPageState extends State<SearchPage> {
  
  TextEditingController _searchController;
  TextField _searchBox; 
  BehaviorSubject<List<Widget>> _searchResults = BehaviorSubject<List<Widget>>()..add([]); // widgets of search result

  int _searchID = 0;
  void _listener() {
    int nowID = ++_searchID;
    String query = "%" + _searchController.text.split(" ").join("%") + "%"; // "Hello world" => "%Hello%World%"
    if (query.length < 5) return; // too short query !
    Future.delayed(Duration(milliseconds: 300), () async {
      if (nowID != _searchID) return;
      var db = CourseProvider.getBloc().courseDB.db;
      List<Widget> results = []
      ..addAll(
        (await db.query("Course", where: "title LIKE ? OR course_no LIKE ?", whereArgs: [query, query]))
        .map((row) => Course.fromJSON(row)).map((course) {
          return CourseItemList(course: course,);
        }).toList()
      )
      ..addAll(
        (await db.query("Announcement", where: "title LIKE ? OR content LIKE ?", whereArgs: [query, query]))
        .map((row) => AnnouncementItem.fromJSON(row)).map((item) {
          return StreamBuilder<Course>(
            stream: CourseProvider.getBloc().getCourseController(item.courseID).info,
            builder: (context, snapshot) {
              return FeedItemListSearch(
                item: item,
                icon: Icon(Icons.info, size: 64),
                courseName: snapshot.data?.name,
              );
            }
          );
        }).toList()
      )
      ..addAll(
        (await db.query("Assignment", where: "title LIKE ? OR instruction LIKE ?", whereArgs: [query, query]))
        .map((row) => AssignmentItem.fromJSON(row)).map((item) { 
          return StreamBuilder<Course>(
            stream: CourseProvider.getBloc().getCourseController(item.courseID).info,
            builder: (context, snapshot) {
              return FeedItemListSearch(
                item: item,
                icon: Icon(Icons.assignment),
                courseName: snapshot.data?.name,
              );
            }
          ); 
        }).toList()
      )
      ..addAll(
        (await db.query("Material", where: "title LIKE ? OR description LIKE ?", whereArgs: [query, query]))
          .map((row) => MaterialItem.fromJSON(row)).map((item) {
            return StreamBuilder<Course>(
              stream: CourseProvider.getBloc().getCourseController(item.courseID).info,
              builder: (context, snapshot) {
                return FeedItemListSearch(
                  item: item,
                  courseName: snapshot.data?.name,
                  icon: CachedNetworkImage(imageUrl: item.thumbnail, width: 48, height: 48,),
                );
              }
            );
          }).toList()
      );
      if (results.isEmpty) results.add(Text("Nothing Matched :("));
      if (!_searchResults.isClosed) _searchResults.add(results);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchBox = TextField(
      autofocus: true,
      controller: _searchController,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: "Search Course",
      ),
    );
    _searchController.addListener(_listener);
  }

  @override 
  void dispose(){
    super.dispose();
    _searchController.removeListener(_listener);
    _searchResults.close();
  }



  Widget build(BuildContext context){
    return Scaffold(
          appBar: AppBar(
            title: _searchBox
          ),
          body: Container(
            padding: EdgeInsets.all(8),
            child: StreamBuilder<List<Widget>>(
              stream: _searchResults,
              builder: (context, snapshot) {
                switch (snapshot.connectionState){
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return ListView(
                      children: snapshot.data
                    );
                  default:
                    return Text("Searching ...");
                }
              },
            )
          ),
        );
    
  }
}