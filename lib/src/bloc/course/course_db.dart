import "dart:async";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";

import '../../models/course.dart';
import '../../models/announcement_item.dart';
import '../../models/material_item.dart';
import '../../models/assignments_item.dart';
import '../../models/graded_item.dart';
import "package:mcv_app/src/util/pair.dart";

const ITEM_OLD_THRESHOLD = Duration(minutes: 15);

class CourseDB {
  Database db;

  
  Future open() async {
    var databasePath =  await getDatabasesPath();
    String path = join(databasePath, "courses.db");
    try {
      db = await openDatabase(path, version: 3, onCreate: _createV2, 
        onUpgrade: (Database db, int oldVersion, int newVersion) {
          if (oldVersion == 1) {
            print("Upgraded from v1 to v2");
            _upgradeToV2();
          } else if (oldVersion == 2) {
            print("Upgrade from v2 to v3");
            _upgradeToV3();
          }
        },
        onOpen: _createMoreTableV2
      );
    } catch (e) {
      print("Error opening Database $e");
    }
  }

  /// open DB if it isn't
  Future prepareDB() async {
    if (db == null || !db.isOpen) await open();
  }

  /// update schema from v1 to v2
  void _upgradeToV2() async {
    await prepareDB();
    db.execute("ALTER TABLE Announcement ADD COLUMN new_flag INTEGER DEFAULT 0");
    db.execute("ALTER TABLE Announcement ADD COLUMN read_flag INTEGER DEFAULT 0");
    db.execute("ALTER TABLE Assignment ADD COLUMN new_flag INTEGER DEFAULT 0");
    db.execute("ALTER TABLE Assignment ADD COLUMN read_flag INTEGER DEFAULT 0");
    db.execute("ALTER TABLE Material ADD COLUMN new_flag INTEGER DEFAULT 0");
    db.execute("ALTER TABLE Material ADD COLUMN read_flag INTEGER DEFAULT 0");
  }

  void _upgradeToV3() async {
    await prepareDB();
    db.execute("ALTER TABLE Course ADD COLUMN following INTEGER DEFAULT 0");
    db.execute("ALTER TABLE GradedItem RENAME COLUMN children TO parent");
  }
 
  /// create database v2
  FutureOr<void> _createV2(Database db, int version) async {
    // CourseTable
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Course (
      cv_cid INTEGER PRIMARY KEY,
      course_no TEXT,
      title TEXT, 
      icon TEXT, year TEXT, semester TEXT, section TEXT, role TEXT, 
      lastMaterial INTEGER DEFAULT 0,
      lastAnnouncement INTEGER INTEGER DEFAULT 0, 
      lastAssignment INTEGER INTEGER DEFAULT 0, 
      lastPlaylist INTEGER INTEGER DEFAULT 0,
      following INTEGER DEFAULT 0
      )
      ''');
    // Announcement
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS Announcement (
        cv_cid INTEGER REFERENCES Course (cv_cid),
        itemid INTEGER PRIMARY KEY,
        title TEXT,
        status INTEGER,
        created INTEGER,
        changed INTEGER,
        content TEXT,
        new_flag INTEGER DEFAULT 0,
        read_flag INTEGER DEFAULT 0
      )
      '''
    );
    // Assignments
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS Assignment (
        cv_cid INTEGER REFERENCES Course (cv_cid),
        itemid INTEGER PRIMARY KEY,
        title TEXT,
        status INTEGER,
        created INTEGER,
        changed INTEGER,
        instruction TEXT,
        outdate TEXT,
        duedate TEXT,
        duetime INTEGER,
        new_flag INTEGER DEFAULT 0,
        read_flag INTEGER DEFAULT 0,
        done_flag INTEGER DEFAULT 0
      )
      '''
    );
    // Materials
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS Material (
        cv_cid INTEGER REFERENCES Course (cv_cid),
        itemid INTEGER PRIMARY KEY,
        title TEXT,
        status INTEGER,
        created INTEGER,
        changed INTEGER,
        description TEXT,
        thumbnail TEXT,
        filepath TEXT,
        new_flag INTEGER DEFAULT 0,
        read_flag INTEGER DEFAULT 0
      )
      '''
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS GradedItem (
      cv_cid INTEGER REFERENCES Course (cv_cid),
      itemid INTEGER PRIMARY KEY,
      title TEXT,
      status INTEGER,
      created INTEGER,
      changed INTEGER,
      raw_total REAL,
      weight_in_group REAL,
      parent INTEGER REFERENCES GradedItem (itemid)
      )
    ''');
  }
 
  /// create more table using old schema of v2
  FutureOr<void> _createMoreTableV2(Database db) async {
    // CourseTable
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Course (
      cv_cid INTEGER PRIMARY KEY,
      course_no TEXT,
      title TEXT, 
      icon TEXT, year TEXT, semester TEXT, section TEXT, role TEXT, 
      lastMaterial INTEGER DEFAULT 0,
      lastAnnouncement INTEGER INTEGER DEFAULT 0, 
      lastAssignment INTEGER INTEGER DEFAULT 0, 
      lastPlaylist INTEGER INTEGER DEFAULT 0,
      following INTEGER DEFAULT 0
      )
      ''');
    // Announcement
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS Announcement (
        cv_cid INTEGER REFERENCES Course (cv_cid),
        itemid INTEGER PRIMARY KEY,
        title TEXT,
        status INTEGER,
        created INTEGER,
        changed INTEGER,
        content TEXT,
        new_flag INTEGER DEFAULT 0,
        read_flag INTEGER DEFAULT 0
      )
      '''
    );
    // Assignments
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS Assignment (
        cv_cid INTEGER REFERENCES Course (cv_cid),
        itemid INTEGER PRIMARY KEY,
        title TEXT,
        status INTEGER,
        created INTEGER,
        changed INTEGER,
        instruction TEXT,
        outdate TEXT,
        duedate TEXT,
        duetime INTEGER,
        new_flag INTEGER DEFAULT 0,
        read_flag INTEGER DEFAULT 0
      )
      '''
    );
    // Materials
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS Material (
        cv_cid INTEGER REFERENCES Course (cv_cid),
        itemid INTEGER PRIMARY KEY,
        title TEXT,
        status INTEGER,
        created INTEGER,
        changed INTEGER,
        description TEXT,
        thumbnail TEXT,
        filepath TEXT,
        new_flag INTEGER DEFAULT 0,
        read_flag INTEGER DEFAULT 0
      )
      '''
    );
    // Graded Items
    await db.execute(
      '''
      CREATE TABLE IF NOT EXISTS Material (
        cv_cid INTEGER REFERENCES Course (cv_cid),
        itemid INTEGER PRIMARY KEY,
        title TEXT,
        status INTEGER,
        created INTEGER,
        changed INTEGER,
        description TEXT,
        thumbnail TEXT,
        filepath TEXT,
        new_flag INTEGER DEFAULT 0,
        read_flag INTEGER DEFAULT 0
      )
      '''
    );

    await db.execute("""
    CREATE TABLE IF NOT EXISTS GradedItem (
      cv_cid INTEGER REFERENCES Course (cv_cid),
      itemid INTEGER PRIMARY KEY,
      title TEXT,
      status INTEGER,
      created INTEGER,
      changed INTEGER,
      raw_total REAL,
      weight_in_group REAL,
      parent INTEGER REFERENCES GradedItem (itemid)
    )
    """);
    // using parent is easier ? that children ?
  }

  /// get list of all courses
  Future<List<Course>> getAllCourses() async {
    await prepareDB();
    var courses = await db.query("Course");
    return courses.map((row) => Course.fromJSON(row)).toList();
  }

  /// return (jsonData, isOld), [jsonData] will be `{}` if not found  
  Future<Course> getCourseInfo(int courseID) async {
    await prepareDB();
    var rows = await db.query("Course",
      where: "cv_cid = ?",
      whereArgs: [courseID],
      columns: ['*']);
    if (rows.length > 0)
      return Course.fromJSON(rows.first);
    return null;
  }


  /// return (List of assignments, isOld), no checking whether [courseID] exists
  Future<List<AssignmentItem>> getCourseAssignments(int courseID) async {
    await prepareDB();
    var assignments = (await db.query("Assignment", 
      where: "cv_cid = ?",
      whereArgs: [courseID],
    ))
    .map((row) => AssignmentItem.fromJSON(row)).toList();
    return assignments;
  }
  
  /// return (List of announcements, isOld), no checking whether [courseID] exists
  Future<List<AnnouncementItem>> getCourseAnnouncements(int courseID) async {
    await prepareDB();
    var announcements = (await db.query("Announcement", 
      where: "cv_cid = ?",
      whereArgs: [courseID],
    ))
    .map((row) => AnnouncementItem.fromJSON(row)).toList();
    return announcements;
  }


  /// return (List of materials, isOld), no checking whether [courseID] exists
  Future<List<MaterialItem>> getCourseMaterials(int courseID) async {
    await prepareDB();
    var materials = (await db.query("Material", 
      where: "cv_cid = ?",
      whereArgs: [courseID],
    ))
    .map((row) => MaterialItem.fromJSON(row)).toList();
    return materials;
  }

  /// return (List of gradedItems, isOld), no checking whether [courseID] exists
  Future<List<GradedItem>> getCourseGradedItems(int courseID) async {
    await prepareDB();
    var gradedItems = (await db.query("GradedItem", 
      where: "cv_cid = ?",
      whereArgs: [courseID], 
    ))
    .map((row) => GradedItem.fromJSON(row));
    return gradedItems;
  }

  Future<int> getCourseNewItemCount(int courseID) {
    return Future.wait([
      db.rawQuery("SELECT COUNT(*) FROM Assignment WHERE cv_cid = ? AND read_flag = 0", [courseID]),
      db.rawQuery("SELECT COUNT(*) FROM Announcement WHERE cv_cid = ? AND read_flag = 0", [courseID]),
      db.rawQuery("SELECT COUNT(*) FROM Material WHERE cv_cid = ? AND read_flag = 0", [courseID])
    ])
    .then((List queryResultList) {
      var counts = queryResultList.map((queryResult) {
        // first row of query result is count
        return ((queryResult as List<Map<String, dynamic>>)[0]["COUNT(*)"] as int);
      }).toList(); 
      return counts.reduce((a, b) => a+b);
    });
  }
 

  Future<Batch> createBatch() async {
    await prepareDB();
    return db.batch();
  } 
  //


}   