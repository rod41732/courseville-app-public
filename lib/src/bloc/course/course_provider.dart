import './course_bloc.dart';
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";
import 'dart:async';
class CourseProvider {
  static CourseBloc _blocInstance; // shared instance of bloc

  static Future delete() async {
    var databasePath =  await getDatabasesPath();
    String path = join(databasePath, "courses.db");
    await deleteDatabase(path);
  }

  static CourseBloc getBloc() {
    if (_blocInstance == null) _blocInstance = CourseBloc();
    return _blocInstance;
  }
}