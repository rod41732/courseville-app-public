
abstract class Item {
  static const Duration OLD_ITEM_THRESHOLD = Duration(days: 15);

  int itemid;
  int courseID;
  String title;
  String type;
  int status;
  // seconds since epoch (NOT millisec)
  int created;
  int changed;
  int newFlag;
  int readFlag;
  Item(this.itemid, this.courseID, this.title, this.type, this.status, this.created, this.changed, this.newFlag, this.readFlag);

  /// this is called after Item instace is created by API call, to
  /// remove readFlag, newFlag
  void afterCreated() {
    if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(this.changed*1000)) > OLD_ITEM_THRESHOLD) {
      this.readFlag = 1;
    }
  }

  String get url;
  bool isDifferentTo(Item other);

}
