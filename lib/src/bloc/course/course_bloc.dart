import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../../models/models.dart';
import '../api.dart' as api;
import "package:sqflite/sqflite.dart";
import "./course_db.dart";
import "course_controller.dart";


typedef void NewItemsHandler(List<Item> newItems);

class CourseBloc {

  CourseDB courseDB = new CourseDB();

  Map<int, CourseController> _controllers = new Map();

  final _feedItems =  BehaviorSubject<List<Item>>()..add([]);
  final _feedItemCount = BehaviorSubject<int>()..add(0);
  final _feedRefreshController = StreamController<int>(); // just send any value to refresh
  final _courses = BehaviorSubject<List<Course>>()..add([]);

  Sink<int> get refresh => _feedRefreshController.sink;
  ValueObservable<List<Item>> get items => _feedItems.stream;
  ValueObservable<List<Course>> get courses => _courses.stream;

  CourseBloc() {
    _feedRefreshController.stream.listen(_refreshFeed);
    getCourses().then((_){
      _refreshFeed(1);
    });
  }

   _refreshCourse(int courseID){
  }

  Future<void> _ensureController(int courseID) async {
    if (!_controllers.containsKey(courseID)) {
      _controllers[courseID] = CourseController(this, courseID);
      await _controllers[courseID].initialize();
    }
  }

  void _refreshFeed(int x) async {
    var allCourses = await getCourses(); 
    List<Item> newItems = new List();
    allCourses.forEach((course) async {
      if (course.year.compareTo("2018") < 0) return;
      int courseID = course.cvCid;
      if (!_controllers.containsKey(courseID)) {
        _controllers[courseID] = CourseController(this, courseID);
      }
      // TODO: this doesn't force fetch yet
      fetchCourseAnnouncements(courseID, unCached: true).then((list) {
        newItems.addAll(list ?? []);
        _feedItems.add(newItems);
      });
      fetchCourseMaterials(courseID, unCached: true).then((list) {
        newItems.addAll(list ?? []);
        _feedItems.add(newItems);
      });
      fetchCourseAssignments(courseID, unCached: true).then((list) {
        newItems.addAll(list ?? []);
        _feedItems.add(newItems);
      });
    });
  }
  // take care of cleaning up
  void dispose(){
    _feedItems.close();
    _feedItemCount.close();
    _feedRefreshController.close();
  }

  CourseController getCourseController(int courseID) {
    _ensureController(courseID);
    return _controllers[courseID];
  }


  Future<Course> getCourseInfo(int courseID) async {
    await _ensureController(courseID);
    return _controllers[courseID].getCourseInfo();
  }
  
  /// Mark specified item as read
  /// itemType are either "material" "announcement" "assignment"
  Future<void> markItemAsRead(String itemType, int itemID) async {
    await courseDB.prepareDB();
    var tableName = itemType[0].toUpperCase() + itemType.substring(1);
    await courseDB.db.update(tableName, {
      "read_flag": 1 
      },
      where: "itemid = ?",
      whereArgs: [itemID],
    );
    return ;
  }

  /// Mark specified item as "done"
  /// itemType are either "material" "announcement" "assignment"
  Future<void> markItemAsDone(String itemType, int itemID)  async {
    await courseDB.prepareDB();
    var tableName = itemType[0].toUpperCase() + itemType.substring(1);
    await courseDB.db.update(tableName, {
      "done_flag": 1 
      },
      where: "itemid = ?",
      whereArgs: [itemID],
    );
    return ;
  }

  
  /// Mark all items for [courseID] as read
  Future<void> markAllItemsAsRead(int courseID) async {
    await courseDB.prepareDB();
    for (final table in <String>["Announcement", "Material", "Assignment"]) {
      await courseDB.db.execute("UPDATE $table SET read_flag = 1 WHERE cv_cid = ?", [courseID]);
    }
    await _ensureController(courseID);
    var ctrl = getCourseController(courseID);
    ctrl.getAnnouncements(offline: true);
    ctrl.getMaterials(offline: true);
    ctrl.getAssignments(offline: true);
  }
  
  /// Delegate call to controller corresponding `courseID` 
  Future<List<AssignmentItem>> fetchCourseAssignments(int courseID, {bool unCached, List<AssignmentItem> newItems, List<AssignmentItem> updatedItems}) async {
    await _ensureController(courseID);
    return await _controllers[courseID].getAssignments(unCached: unCached, newItems: newItems, updatedItems: updatedItems); // TODO: this don't refresh yet
  }
  
  /// Delegate call to controller corresponding `courseID` 
  Future<List<AnnouncementItem>> fetchCourseAnnouncements(int courseID, {bool unCached, List<AnnouncementItem> newItems, List<AnnouncementItem> updatedItems}) async {
    await _ensureController(courseID);
    return await _controllers[courseID].getAnnouncements(unCached: unCached, newItems: newItems, updatedItems: updatedItems);
  }  
  
  /// Delegate call to controller corresponding `courseID` 
  Future<List<MaterialItem>> fetchCourseMaterials(int courseID, {bool unCached, List<MaterialItem> newItems, List<MaterialItem> updatedItems}) async {
    await _ensureController(courseID);
    return await _controllers[courseID].getMaterials(unCached: unCached, newItems: newItems, updatedItems: updatedItems);
  }
  // get course graded items from DB or API -- Note: API isn't ready yet
  Future<List<GradedItem>> getCourseGradedItems(int courseID) async {
    return api.getCourseItems(courseID, "graded_items", 1)
    .then((response) async{
      var gradedItemsList = (response['data'] as List<dynamic>).cast<Map<String, dynamic>>();
      return gradedItemsList.map((json) => GradedItem.fromJSON(json)).toList();
    });
  }

  // get list of all courses
  // should call more that once
  Future<List<Course>> getCourses({bool refresh = false}) async {
    var fromDB = await courseDB.getAllCourses();
    _courses.add(fromDB);
    if (fromDB.any((course) => course.name == "") || fromDB.length == 0 || refresh)
      return api.getCourses()
      .then((resultCourses) async {
        var courses = List<Course>.from((resultCourses['data']['student'] as List<dynamic>).map((data) => Course.fromJSON(data)));
        courses.addAll(((resultCourses['data']['staff'] ?? []) as List<dynamic>).map((data) => Course.fromJSON(data)));
        var batch = courseDB.db.batch();
        courses.forEach((course) async { 
          batch.insert("Course", course.toJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
        });
        await batch.commit(noResult: true);
        _courses.add(courses);
        return courses;
      });
    else{
      return fromDB;
    }
  }
}