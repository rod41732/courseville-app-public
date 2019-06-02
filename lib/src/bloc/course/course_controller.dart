import "dart:async";
import 'package:mcv_app/src/bloc/course/course_provider.dart';

import "course_bloc.dart";
import "package:sqflite/sqflite.dart";
import "package:mcv_app/src/models/models.dart";
import "package:rxdart/rxdart.dart";
import "../api.dart" as api;


int compareItem<T extends Item> (T a, T b) {
  return a.itemid - b.itemid;
}

const ITEM_OLD_THRESHOLD = Duration(minutes: 30);
const QUICK_ITEM_OLD_THRESHOLD = Duration(minutes: 3);

class CourseController {
  final CourseBloc bloc; // to reference parent
  final int courseID;
  BehaviorSubject<Course> info = BehaviorSubject<Course>()..add(null);
  Course _currentInfo;
  BehaviorSubject<List<MaterialItem>> materials = BehaviorSubject<List<MaterialItem>>()..add([]);
  BehaviorSubject<List<AssignmentItem>> assignments = BehaviorSubject<List<AssignmentItem>>()..add([]);
  BehaviorSubject<List<AnnouncementItem>> announcements = BehaviorSubject<List<AnnouncementItem>>()..add([]);
  BehaviorSubject<int> newMaterialCount = BehaviorSubject<int>()..add(0);
  BehaviorSubject<int> newAssignmentCount = BehaviorSubject<int>()..add(0);
  BehaviorSubject<int> newAnnouncementCount = BehaviorSubject<int>()..add(0);

  bool _getInfoLock = false;
  bool _getAnnouncementsLock = false;
  bool _getMaterialsLock = false;
  bool _getAssignmentsLock = false;

  String _toTitleCase(String str) {
    if (str == "") return "";
    return str.substring(0, 1).toUpperCase() + str.substring(1).toLowerCase();  
  }

  Future<void> _diffAndStore(List<Item> old, List<Item> updated, List<Item> newItemOut, List<Item> updatedItemOut, List<Item> union) async {
    updated.sort((a, b) => a.itemid - b.itemid);
    old.sort((a, b) => a.itemid - b.itemid);
    int iold = 0, inew = 0;
    // Diffing , O(n log n)
    if (newItemOut == null) newItemOut = List(); //Prevent NPE
    if (updatedItemOut == null) updatedItemOut = List(); //Prevent NPE
    if (union == null) union = List();
    var batch = await CourseProvider.getBloc().courseDB.createBatch();
    while (iold < old.length && inew < updated.length) {
      if (old[iold].itemid < updated[inew].itemid){
        batch.delete(_toTitleCase(old[iold].type), where: "itemid = ? ", whereArgs: [old[iold].itemid]);
        print("remove ${old[iold]}");
        ++iold;
      }
      else if (updated[inew].itemid < old[iold].itemid){
        newItemOut.add(updated[inew]);
        union.add(updated[inew]);
        ++inew;
      }
      else {
        if (updated[inew].isDifferentTo(old[iold])){
          updatedItemOut.add(updated[inew]);
          union.add(updated[inew]);
        } else {
          union.add(old[iold]);
        }
        ++inew;
        ++iold;
      } 
    }
    while (inew < updated.length) {
      newItemOut.add(updated[inew]);
      union.add(updated[inew]);
      ++inew;
    }
    while (iold < old.length) {
      batch.delete(_toTitleCase(old[iold].type), where: "itemid = ?", whereArgs: [old[iold].itemid]);
      ++iold;
    }
    await batch.commit(noResult: true);
  }


  CourseController(this.bloc, this.courseID);

  Future<void> initialize() async {
    
    var course = await getCourseInfo();
    await bloc.courseDB.db.insert("Course", course.toJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
    print("============== added info");
    info.add(course);
    _currentInfo = course;
  }

  Future<Course> getCourseInfo({bool refresh = false}) async {
    try {
      var oldCourse = await this.bloc.courseDB.getCourseInfo(courseID);
      this._currentInfo = oldCourse;
      this.info.add(oldCourse);
      if (oldCourse != null && oldCourse.name != "") { // non-empty map = has result
        return oldCourse;
      }
      var course = Course.fromJSON(await api.getCourseData(this.courseID));
      await bloc.courseDB.db.insert("Course", course.toJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
      this.info.add(course);
      this._currentInfo = course;
      return course;
    } catch (e) {

    } 
    return null;
  }

  Future<List<AnnouncementItem>> getAnnouncements({bool unCached: false, bool offline: false, List<AnnouncementItem> newItems, List<AnnouncementItem> updatedItems}) async {
    if (_getAnnouncementsLock) {
      while (_getAnnouncementsLock) {
          await Future.delayed(Duration(milliseconds: 2));
      }
      return await announcements.last;
    }
    _getAnnouncementsLock = true;
    var courseDB = bloc.courseDB;
    var result = await courseDB.getCourseAnnouncements(courseID);
    if (_currentInfo == null) {
      _currentInfo = await getCourseInfo();
    }
    var isOld = _isOld(_currentInfo.lastFetchedAnnouncement, unCached);
    announcements.add(result);
    Map<String, dynamic> resp;
    try {
      if (!isOld || (offline ?? false)) {    
        return result;
      }
      resp = await api.getCourseItems(courseID, "announcements", 1);
      if (resp['data'] is List<dynamic>){ // Not "Too many attempts"
        var updated = (resp['data'] as List<dynamic>).cast<Map<String, dynamic>>().map((json) {
          json['cv_cid'] = courseID;
          return AnnouncementItem.fromJSON(json)..afterCreated();
        }).toList();
        newItems = newItems ?? List();
        updatedItems = updatedItems ?? List();
        List<AnnouncementItem> allItems = List();
        _diffAndStore(result, updated, newItems, updatedItems, allItems);
        var batch = await courseDB.createBatch();
        newItems.forEach((item) {
          batch.insert("Announcement", item.toDBJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
        });
        updatedItems.forEach((item) {
          batch.insert("Announcement", item.toDBJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
        });
        await batch.commit(noResult: true);
        _currentInfo.lastFetchedAnnouncement = DateTime.now().millisecondsSinceEpoch~/1000;
        await bloc.courseDB.db.update("Course", {"lastAnnouncement": _currentInfo.lastFetchedAnnouncement}, where: "cv_cid = ?", whereArgs: [_currentInfo.cvCid]);
        return result = allItems; 
      }
    } catch (e) {
      print("Error Getting Announcements $e");
    } finally {
      _getAnnouncementsLock = false;
      announcements.add(result);
      newAnnouncementCount.add(result.where((item) => item.readFlag == 0).length);
    }
    return result;
  }

  Future<List<AssignmentItem>> getAssignments({bool unCached = false, bool offline = false, List<AssignmentItem> newItems, List<AssignmentItem> updatedItems}) async {
    if (_getAssignmentsLock) {
      while (_getAssignmentsLock) {
          await Future.delayed(Duration(milliseconds: 2));
      }
      return await assignments.last;
    }
    _getAssignmentsLock = true;
    var courseDB = bloc.courseDB;
    var result = await courseDB.getCourseAssignments(courseID);
    if (_currentInfo == null) {
      _currentInfo = await getCourseInfo();
    }
    var isOld = _isOld(_currentInfo.lastFetchedAssignment, unCached);
    assignments.add(result);
    Map<String, dynamic> resp;
    try {
      if (!isOld || (offline ?? false)) {
        return result;
      }
      resp = await api.getCourseItems(courseID, "assignments", 1);
      if (resp['data'] is List<dynamic>){ // Not "Too many attempts"
        var updated = (resp['data'] as List<dynamic>).cast<Map<String, dynamic>>().map((json) {
          json['cv_cid'] = courseID;
          return AssignmentItem.fromJSON(json)..afterCreated();
        }).toList();
        newItems = newItems ?? List(); 
        updatedItems = updatedItems ?? List();
        List<AssignmentItem> allItems = List();
        _diffAndStore(result, updated, newItems, updatedItems, allItems);
        var batch = await courseDB.createBatch();
        newItems.forEach((item) {
          batch.insert("Assignment", item.toDBJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
        });
        updatedItems.forEach((item) {
          batch.insert("Assignment", item.toDBJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
        });
        await batch.commit(noResult: true);
        _currentInfo.lastFetchedAssignment = DateTime.now().millisecondsSinceEpoch~/1000;
        bloc.courseDB.db.update("Course", {"lastAssignment": _currentInfo.lastFetchedAssignment}, where: "cv_cid = ?", whereArgs: [_currentInfo.cvCid]);
        return result = allItems; 
      }
    } catch (e) {
      print("Error Getting Assingments $e");
    } finally {
      _getAssignmentsLock = false;
      assignments.add(result);
      newAssignmentCount.add(result.where((item) => item.readFlag == 0).length);
    }
    return result;
  }

  Future<List<MaterialItem>> getMaterials({bool unCached: false, bool offline: false, List<MaterialItem> newItems, List<MaterialItem> updatedItems}) async {
    if (_getMaterialsLock) {
      while (_getMaterialsLock) {
          await Future.delayed(Duration(milliseconds: 2));
      }
      return await materials.last;
    }
    _getMaterialsLock = true;
    var courseDB = bloc.courseDB;
    var result = await courseDB.getCourseMaterials(courseID);
    if (_currentInfo == null) {
      _currentInfo = await getCourseInfo();
    }
    var isOld = _isOld(_currentInfo.lastFetchedMaterial, unCached);
    materials.add(result);
    Map<String, dynamic> resp;
    try {
      if (!isOld || (offline ?? false)) {
        return result;
      }
      resp = await api.getCourseItems(courseID, "materials", 1);
      if (resp['data'] is List<dynamic>){ // Not "Too many attempts"
        var updated = (resp['data'] as List<dynamic>).cast<Map<String, dynamic>>().map((json) {
          json['cv_cid'] = courseID;
          return MaterialItem.fromJSON(json)..afterCreated();
        }).toList();
        newItems = newItems ?? List();
        updatedItems = updatedItems ?? List();
        List<MaterialItem> allItems = List();
        await _diffAndStore(result, updated, newItems, updatedItems, allItems);
        var batch = await courseDB.createBatch();
        newItems.forEach((item) {
          batch.insert("Material", item.toDBJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
        });
        updatedItems.forEach((item) {
          batch.insert("Material", item.toDBJSON(), conflictAlgorithm: ConflictAlgorithm.replace);
        });
        await batch.commit(noResult: true);
        _currentInfo.lastFetchedMaterial = DateTime.now().millisecondsSinceEpoch~/1000;
        bloc.courseDB.db.update("Course", {"lastMaterial": _currentInfo.lastFetchedMaterial}, where: "cv_cid = ?", whereArgs: [_currentInfo.cvCid]);
        return result = allItems; 
      }
    } catch (e) {
      print("Error Getting Material $e");
    } finally {
      _getMaterialsLock = false;
      newMaterialCount.add(result.where((item) => item.readFlag == 0).length);
      materials.add(result);        
    }
    return result; 
  }

    
  /// set following flag for course, 0 = default, 1 = ON, 2 = OFF 
  Future<void> setFollowing(int following) async {
    bloc.courseDB.db.update("Course", {"following": following}, where: "cv_cid = ?", whereArgs: [courseID])
    .then((_) {
      _currentInfo.following = following;
      info.add(_currentInfo);
    })
    .catchError((err) {
      print("Error updating following state of $courseID :  $err");
    });
  }


  void dispose(){
    info.close();
    materials.close();
    announcements.close();
  }

  /// [uncached] determines threshold of "old"
  bool _isOld(int secondsSinceEpoch, bool unCached) {
    var past = DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch*1000);
    return DateTime.now().difference(past) > (unCached ? QUICK_ITEM_OLD_THRESHOLD : ITEM_OLD_THRESHOLD); 
  }


}
