class Course {
  static const schema = '''
        cv_cid INTEGER PRIMARY KEY,
        courseNo TEXT, name TEXT, 
      icon TEXT, year TEXT, semester TEXT, section TEXT, role TEXT, 
      lastMaterial INTEGER DEFAULT 0,
      lastAnnouncement INTEGER INTEGER DEFAULT 0, 
      lastAssignment INTEGER INTEGER DEFAULT 0, 
      lastPlaylist INTEGER INTEGER DEFAULT 0
  ''';

  int cvCid; // courseville ID for APIs
  String courseNo; 
  String name;
  String icon;
  // as then API return these fields as String so I will use string 
  String year;
  String semester;
  String section;
  String role;
  int lastFetchedAnnouncement;
  int lastFetchedAssignment;
  int lastFetchedMaterial;
  int following;

  Course.fromJSON(Map<String, dynamic> json) 
    : cvCid = json['cv_cid'],
    courseNo = json['course_no'] ?? json['courseNo'],
    name = json['title'] ?? json['name'] ?? "",
    icon = json['course_icon'] ?? json['icon'] ?? "https://www.mycourseville.com/sites/all/modules/courseville/files/thumbs/icon_2110200_2014_2_1438051233_1499047086.png",
    year = json['year'],
    semester = json['semester'].toString(),
    section = json['section'].toString(),
    role = json['role'].toString(),
    lastFetchedAssignment = json['lastAssignment'] ?? 0,
    lastFetchedAnnouncement = json['lastAnnouncement'] ?? 0,
    lastFetchedMaterial = json['lastMaterial'] ?? 0,
    following = json['following'] ?? 0;

  Map<String, dynamic> toJSON() {
    return {
      "course_no":courseNo, 
      "cv_cid":cvCid,
      "title":name,
      "icon":icon,
      "year":year,
      "semester":semester,
      "section":section,
      "role":role,
      "lastAssignment": lastFetchedAssignment,
      "lastAnnouncement": lastFetchedAnnouncement,
      "lastMaterial": lastFetchedMaterial,
      "following": following,
   };
  }


}