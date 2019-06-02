import 'package:flutter/material.dart';
import 'package:mcv_app/src/bloc/application/profile.dart';
import 'package:mcv_app/src/pages/course_detail/couse_info.dart';

class ProfilePage extends StatelessWidget {
  
  
  Future<void>  _refresh() async {
    ProfileProvider.instance.getProfile(refresh: true);
    return;
  }

  @override
  Widget build(BuildContext context) {
   final GlobalKey<RefreshIndicatorState> _refreshIndicatorState = GlobalKey<RefreshIndicatorState>();
    return RefreshIndicator(
      onRefresh: _refresh,
      key: _refreshIndicatorState,
      child: StreamBuilder<Profile>(
        stream: ProfileProvider.instance.profile,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
              var profile = snapshot.data; 
              return ListView(
                children: <Widget>[
                  InfoEntry(fieldName: "Name (TH)", fieldData: profile.getNameTH(),),
                  InfoEntry(fieldName: "Name (EN)", fieldData: profile.getNameEN(),),
                  InfoEntry(fieldName: "Student ID", fieldData: profile.studentID,),
                  InfoEntry(fieldName: "Degree", fieldData: profile.degree,),
                ],
              );
            default:
              return Container(width: 0, height: 0,);
          }
        },
      ),
    );
  }
}
