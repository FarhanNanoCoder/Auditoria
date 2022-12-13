import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Toast{
  BuildContext context;
  Widget widget;
  Toast({this.context,this.widget});
  showToast() async {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context)=>Positioned(
        bottom: 44,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Center(child: widget,),
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    await Future.delayed(Duration(milliseconds: 1500,));
    overlayEntry.remove();
  }

  showTextToast(String text) async {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context)=>Positioned(
        bottom: 44,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
            decoration: BoxDecoration(
              color: AppColors().grey900,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  //offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: AppText(text: text,style: 'regular',size: 12,color: AppColors().white).getText()),
          ),
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    await Future.delayed(Duration(milliseconds: 3000,));
    overlayEntry.remove();
  }
}