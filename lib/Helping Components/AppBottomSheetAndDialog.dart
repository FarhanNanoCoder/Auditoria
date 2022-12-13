import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AppColors.dart';
import 'AppText.dart';

class AppBottomSheet{
  final List<IconData> icons;
  final List<String> buttonNames;
  final Function(int index) onButtonTap;
  final BuildContext parentContext;
  double height;

  AppBottomSheet({this.icons, this.buttonNames, this.onButtonTap, this.parentContext});

  void viewModalBottomSheet(){
    height = (56 + icons.length*56)*1.0;
    showModalBottomSheet(
        context: parentContext,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.02),
        elevation: 5,
        builder: (context){
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              height: height,
              padding: EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight:Radius.circular(16) ),
                color: AppColors().white,
              ),
              child: Column(
                children: [
                  SizedBox(height: 4,),
                  Center(
                    child: Container(
                      height: 4,
                      width: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors().themeDarkBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 24,),
                  IconWithTextButton(
                    onButtonTap: (index){
                      Navigator.pop(parentContext);
                      onButtonTap(index);
                    },
                    icons: icons,
                    buttonNames: buttonNames,
                  ),
                  SizedBox(height: 24,),
                ],
              ),
            ),
          );
        });
  }
}

class IconWithTextButton extends StatelessWidget{
  final List<IconData> icons;
  final List<String> buttonNames;
  final Function(int index) onButtonTap;
  final BuildContext parentContext;

  IconWithTextButton({this.icons, this.buttonNames, this.onButtonTap,this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: icons.map((e) => Container(
        width: MediaQuery.of(context).size.width,
        height: 56,
        child: TextButton(
          onPressed: (){
            onButtonTap(icons.indexOf(e));
          },
          child: Row(
            children: [
              Icon(e,size: 24,color: AppColors().themeDarkBlue,),
              SizedBox(width: 24,),
              AppText(
                text: buttonNames[icons.indexOf(e)],
                style: 'regular',
                size: 16,
                color: AppColors().themeDarkBlue,
              ).getText()
            ],
          ),
        ),
      )).toList(),
    );
  }
}

showAppDialog({BuildContext context,Widget child,bool barrierDismissible=true}){
  showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.transparent,
      builder: (context){
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: child
          ),
        );
      }
  );
}