import './item.dart';

class MaterialItem extends Item {
  String description;
  String thumbnail;
  String filepath;

  MaterialItem(int itemid, int courseID, String title, int status, int created, int changed,
  this.description, this.thumbnail, this.filepath, {int newFlag, int readFlag}) :
    super(itemid, courseID, title, "material", status, created, changed,
    newFlag ?? 0, readFlag ?? 0);
  
   MaterialItem.fromJSON(Map<String, dynamic> json) :
    this(json['itemid'], json['cv_cid'], json['title'], json['status'],
    json['created'], json['changed'], json['description'],
    json['thumbnail'], json['filepath'],
    newFlag: json['new_flag'], readFlag: json['read_flag']) ;

  Map<String, dynamic> toDBJSON() {
    return {
      'itemid': itemid,
      'cv_cid': courseID,
      'title': title,
      'status': status,
      'created': created,
      'changed': changed,
      'description': description,
      'thumbnail': thumbnail,
      'filepath': filepath,
      'new_flag': newFlag,
      'read_flag': readFlag,
    };
  }
  String get url => "https://www.mycourseville.com/?q=courseville/course/$courseID/material/$itemid";

  @override
  bool isDifferentTo(Item other) {
    if (other is MaterialItem) {
      return other.description != this.description || other.title != this.title || other.itemid != this.itemid 
      || this.filepath != other.filepath || this.thumbnail != other.thumbnail;
    } 
    return true;
  } 
}