import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:flutter/material.dart';

class TopAppBar extends   StatelessWidget{
  IconData leftButtonIcon,rightButtonIcon;
  String pageTitle;
  Function() onLeftButtonTap;
  Function() onRightButtonTap;

  TopAppBar({this.leftButtonIcon, this.rightButtonIcon, this.pageTitle,
    this.onLeftButtonTap,this.onRightButtonTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      width: MediaQuery.of(context).size.width,
      height: 56,
      color: Colors.transparent,
      child: Stack(
        children: [
          leftButtonIcon!=null?
              Align(
                alignment: Alignment(-1,0),
                child: IconButton(
                  onPressed: (){
                    onLeftButtonTap();
                  },
                  icon: Icon(leftButtonIcon),
                  iconSize: 24,
                  color: AppColors().themeDarkBlue,
                ),
              ):SizedBox(width: 24,height: 24,),
          pageTitle!=null?Center(
            child: AppText(text: pageTitle,size: 16,style: 'regular',
                color: AppColors().themeDarkBlue).getText(),
          ):SizedBox(width: 24,height: 24,),
          rightButtonIcon!=null?
          Align(
            alignment: Alignment(1,0),
            child: IconButton(
              onPressed: (){
                onRightButtonTap();
              },
              icon: Icon(rightButtonIcon),
              iconSize: 24,
              color: AppColors().themeDarkBlue,
            ),
          ):SizedBox(width: 24,height: 24,),
        ],
      ),
    );
  }

}
