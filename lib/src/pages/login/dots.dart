import 'package:flutter/material.dart';

class DotIndicator extends StatefulWidget {
  final TabController controller;
  const DotIndicator({Key key, this.controller}) : super(key: key);

  _DotIndicatorState createState() => _DotIndicatorState(controller.index);
}

class _DotIndicatorState extends State<DotIndicator> {
  
  int currentPage = 0;
  _DotIndicatorState(this.currentPage);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        currentPage = widget.controller.index;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    var len = widget.controller.length;
    return Container( 
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(len, (idx) { 
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Dot(isActive: idx == currentPage,),
          );
        })
      ),
    );
  }
}


class Dot extends StatelessWidget {
  final bool isActive;

  const Dot({Key key, this.isActive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isActive ? Colors.white : Colors.white30,
      ),
      child: Container(width: 0, height: 0,),
    );
  }



}
