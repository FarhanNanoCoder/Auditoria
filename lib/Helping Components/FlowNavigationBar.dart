import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FlowNavigationBar extends StatefulWidget{
  List<IconData> icons =[];
  Color circleColor = AppColors().themeDarkBlue,
      backgroundColor = AppColors().white,
      iconColor = AppColors().themeDarkBlue,
      activeIconColor=AppColors().white;
  double height = 56,iconSize=24;
  int initialIndex = 0;
  int length = 0;
  final Function (int position) onIndexChangedListener;

  FlowNavigationBar({this.icons, this.circleColor, this.backgroundColor,
      this.iconColor, this.activeIconColor, this.height, this.iconSize,this.initialIndex,
  this.onIndexChangedListener});


  @override
  _FlowNavigationBarState createState() => _FlowNavigationBarState();
}

class _FlowNavigationBarState extends State<FlowNavigationBar> {
  @override
  Widget build(BuildContext context) {
    int currentIndex =widget.initialIndex;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            left: MediaQuery.of(context).size.width*((currentIndex)/widget.icons.length),
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width*(1/widget.icons.length),
              height: widget.height,
              child: Center(
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: widget.circleColor,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: widget.icons.map((e) => SizedBox(
              width: MediaQuery.of(context).size.width*(1/widget.icons.length),
              height: widget.height,
              child: Center(
                child: IconButton(
                  onPressed: (){
                    setState(() {
                      currentIndex = widget.icons.indexOf(e);
                      widget.onIndexChangedListener(currentIndex);
                    });
                  },
                  icon: Icon(e,),
                  iconSize: widget.iconSize,
                  color: currentIndex == widget.icons.indexOf(e)?
                  widget.activeIconColor:widget.iconColor,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}