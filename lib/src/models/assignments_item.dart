import './item.dart';

class AssignmentItem extends Item {
  String instruction;
  String outdate;
  String duedate;
  // seconds since epoch (NOT millisec)
  int duetime;

  AssignmentItem(int itemid, int courseID, String title, int status, int created, int changed,
  this.instruction, this.outdate, this.duedate, this.duetime,
  {int newFlag, int readFlag}) :
    super(itemid, courseID, title, "assignment", status, created, changed,
    newFlag ?? 0, readFlag ?? 0);
  
  AssignmentItem.fromJSON(Map<String, dynamic> json) :
    this(json['itemid'], json['cv_cid'], json['title'], json['status'],
    json['created'], json['changed'], json['instruction'],
    json['outdate'], json['duedate'], json['duetime'],
    newFlag: json['new_flag'], readFlag: json['read_flag']);

  Map<String, dynamic> toDBJSON() {
    return {
      'itemid': itemid,
      'cv_cid': courseID,
      'title': title,
      'status': status,
      'created': created,
      'changed': changed,
      'instruction': instruction,
      'duedate': duedate,
      'duetime': duetime,
      'new_flag': newFlag,
      'read_flag': readFlag,
    };
  }

  String get url => 'https://www.mycourseville.com/?q=courseville/worksheet/$courseID/$itemid';
  
  @override
  bool isDifferentTo(Item other) {
    if (other is AssignmentItem) {
      return other.instruction != this.instruction || other.title != this.title || other.itemid != this.itemid
     || this.duedate != other.duedate || this.duetime != other.duetime;
    } 
    return true;
  }


}