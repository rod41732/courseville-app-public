import 'package:mcv_app/src/bloc/application/application_db.dart';
import 'package:rxdart/rxdart.dart';



class SettingsManager {
  
  static const String RECENT_ITEM_AGE = "recentItemAge"; 

  static SettingsManager instance = SettingsManager();
  BehaviorSubject<int> recentItemAge = BehaviorSubject(); // How old item can be shown in feed;

  SettingsManager() {

    ApplicationDB.instance.getInt(RECENT_ITEM_AGE)
    .then((val) {
      recentItemAge.add(val ?? 15); // default is 15 days when null
    });
    recentItemAge.listen((val) {
      ApplicationDB.instance.set(RECENT_ITEM_AGE, val.toString());
    });
  }

}