import 'application_db.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';
import '../api.dart' as api; 

class Profile {

  String titleEN, firstNameEN, lastNameEN;
  String titleTH, firstNameTH, lastNameTH;
  String degree;
  String studentID;
  
  Profile(this.titleEN, this.firstNameEN, this.lastNameEN,
    this.titleTH, this.firstNameTH, this.lastNameTH,
    this.degree, this.studentID);
  Profile.fromJSON(Map<String, dynamic> json) {
    Map<String, dynamic> data = json;
    titleEN = data['title_en'];
    firstNameEN = data['firstname_en'];
    lastNameEN = data['lastname_en'];
    titleTH = data['title_th'];
    firstNameTH = data['firstname_th'];
    lastNameTH = data['lastname_th'];
    degree = data['degree'];
    studentID = data['id'].toString();
  }

  @override 
  String toString() {
    return json.encode({
      'title_en': titleEN,
      'firstname_en': firstNameEN,
      'lastname_en': lastNameEN,
      'title_th': titleTH,
      'firstname_th': firstNameTH,
      'lastname_th': lastNameTH,
      'degree': degree,
      'id': studentID
    });
  }

  factory Profile.empty() {
    return Profile("Mr", "X", "X",  "นาย", "X", "X", "-", "0000000000");
  }

  String getNameEN() {
    return "$titleEN $firstNameEN $lastNameEN";
  }

  String getNameTH() {
    return "$titleTH $firstNameTH $lastNameTH";
  }
}

class ProfileProvider {
  static final ProfileProvider instance = ProfileProvider();
  static const String PROFILE = "profile";
  static const String UPDATED = "lastUpdatedProfile";
  
  BehaviorSubject<Profile> profile = BehaviorSubject<Profile>();
  BehaviorSubject<int> _updated = BehaviorSubject<int>();

  ProfileProvider() {
    ApplicationDB.instance.get(PROFILE)
    .then((val) {
      try {
        var newProfile = Profile.fromJSON(json.decode(val));
        profile.sink.add(newProfile);
      } catch (e) {
        profile.add(Profile.empty());
      }
    });

    ApplicationDB.instance.getInt(UPDATED)
    .then((val) {
      _updated.sink.add(val ?? 0);
    });

    _updated.listen((lastUpdate) {
      ApplicationDB.instance.set(UPDATED, lastUpdate.toString());
    });

    profile.listen((jsonResult) {
      ApplicationDB.instance.set(PROFILE, jsonResult.toString());
    });
  }

  bool _isOld(int millis) {
    return DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(millis)) > Duration(days: 1);
  }

  Future<Profile> getProfile({bool refresh = false}) async {
    if (_isOld(await ApplicationDB.instance.getInt(UPDATED) ?? 0) || refresh) {
      api.getUserInfo().then((jsonResult) {
        var newProfile = Profile.fromJSON(jsonResult['data']['student']);
        profile.add(newProfile);
        _updated.add(DateTime.now().millisecondsSinceEpoch);
        return newProfile;
      });
    }
    return await profile.last;
  }

}