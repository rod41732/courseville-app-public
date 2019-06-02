import "package:flutter/material.dart";
import 'package:mcv_app/src/components/graded_item_base.dart';
import "../../models/graded_item.dart";
import "../../bloc/course/course_provider.dart";
class CourseScore extends StatelessWidget { // TODO: stateful = sort, filter etc
  final int courseID; 
  CourseScore(this.courseID);

  @override Widget build(BuildContext context) {
    return FutureBuilder<List<GradedItem>>(
      initialData: <GradedItem>[],
      future: CourseProvider.getBloc().getCourseGradedItems(courseID),
      builder: (BuildContext context, AsyncSnapshot<List<GradedItem>> snapshot) {
        List<GradedItem> gradedItems = snapshot.hasError ? <GradedItem>[] :snapshot.data;
        if (gradedItems.length > 0)
          return ListView(
            children: gradedItems.map((item) => GradedItemWidgetBase(item)).toList()
          ); 
        return Center(
          child: Column(
            children: [
              Text("NO DATA",
                style: Theme.of(context).textTheme.title.apply(fontSizeFactor: 1.2),
              )
            ],
          ),
        );
      } 
    );
  }
}
