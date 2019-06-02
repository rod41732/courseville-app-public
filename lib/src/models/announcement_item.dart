import './item.dart';
class AnnouncementItem extends Item {
  String content;

  AnnouncementItem(int itemid, int courseID, String title, int status, int created, int changed,
  this.content, {int newFlag, int readFlag}) :
    super(itemid, courseID, title, "announcement", status, created, changed, newFlag ?? 0, readFlag ?? 0);

  AnnouncementItem.fromJSON(Map<String, dynamic> json) :
    this(json['itemid'], json['cv_cid'], json['title'], json['status'], 
    json['created'], json['changed'], json['content'],
    newFlag: json['new_flag'], readFlag: json['read_flag']) ;

  Map<String, dynamic> toDBJSON() {
    return {
      'itemid': itemid,
      'cv_cid': courseID,
      'title': title,
      'status': status,
      'created': created,
      'changed': changed,
      'content': content,
      'new_flag': newFlag,
      'read_flag': readFlag,
    };
  }

  String get url => "https://www.mycourseville.com/?q=courseville/course/$courseID/announcement/$itemid";

  @override
  bool isDifferentTo(Item other) {
    if (other is AnnouncementItem) {
      return other.content != this.content || other.title != this.title || other.itemid != this.itemid;
    } 
    return true;
  }

 
  
}