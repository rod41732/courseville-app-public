import './item.dart';

class GradedItem extends Item {
  double rawTotal;
  double weightInGroup;
  List<GradedItem> children;
  
  GradedItem(int itemid, int courseID, String title, int status, int created, int changed,
  this.rawTotal, this.weightInGroup, this.children, {int newFlag, int readFlag}) :
    super(itemid, courseID, title, "graded_item", status, created, changed,
    newFlag ?? 0, readFlag ?? 0);
  
  GradedItem.fromJSON(Map<String, dynamic> json) :
    super(json['item_id'], json['cv_cid'], json['title'], "graded_item",json['status'],
    json['created'], json['changed'], json['new_flag'], json['read_flag']) {
      this.rawTotal = json['raw_total'].toDouble();
      this.weightInGroup = json['weight_in_group'].toDouble();
      try {
        this.children = (json['children'] as List<dynamic>).cast<Map<String, dynamic>>()
        .map((subJson) => GradedItem.fromJSON(subJson))
        .toList();
      } 
      catch (err) {
        print("Error parsing ${json['children']} ${err.toString()}");
        this.children = null;
      }
  }

  @override
  bool isDifferentTo(Item other) {
    if (other is GradedItem) {
      return rawTotal != other.rawTotal || other.weightInGroup != other.weightInGroup || other.itemid != this.itemid;
    }
    return true;
  }

  String get url => "https://www.mycourseville.com"; // TODO: Not yet implemented

}