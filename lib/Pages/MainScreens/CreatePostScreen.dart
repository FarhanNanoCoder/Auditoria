import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Pages/ExtensionsOfCreatePostScreen/CreatingPostScreen.dart';
import 'package:auditoria/Pages/ExtensionsOfCreatePostScreen/CreatingPostScreenNew.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';

// ignore: must_be_immutable
class CreatePostScreen extends StatelessWidget{
  String wishing='Good day',svgPath='assets/svg/',username ='Buddy';
  getSvgPath(){
    var hour = DateTime.now().hour;
    if(hour<6){
      wishing = 'Good night';
      svgPath= svgPath+'night_.svg';
    }else if(hour<12){
      wishing = 'Good morning';
      svgPath= svgPath+'morning_.svg';
    }else if(hour<18){
      wishing = 'Good afternoon';
      svgPath= svgPath+'afternoon_.svg';
    }else{
      wishing = 'Good evening';
      svgPath= svgPath+'evening_.svg';
    }
  }
  @override
  Widget build(BuildContext context) {
    getSvgPath();
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 24,vertical: 24),
          child: Column(
            children: [
              SizedBox(height: 56,),
              //GraphicsViewer(),
              WebsafeSvg.asset('assets/svg/palette_.svg',height: 200),
              SizedBox(height: 24,),
              AppText(text: 'Think a lot to explore your idea',style: 'regular',size: 14,color: AppColors().themeOffBlue).getText(),
              SizedBox(height: 56,),
              AppText(text: '"Inspiration exists, but it has to find you working"'
                  ,style: 'semibold',size: 18,color: AppColors().themeBrown).getText(),
              SizedBox(height: 24,),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 8,vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(width: 1,color: AppColors().grey200),
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors().white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WebsafeSvg.asset(svgPath,height: 36,),
                        SizedBox(width: 24,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AppText(text: wishing
                                ,style: 'regular',size: 12,color: AppColors().themeDarkBlue).getText(),
                            AppText(text: username
                                ,style: 'medium',size: 16,color: AppColors().themeDarkBlue).getText(),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16,),
                    AppText(text: 'What\'s on your mind? let\'s work on it and polish your idea. Hope you will find something amazing'
                        ,style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
                  ],
                ),
              ),
              SizedBox(height: 56,),
              TextButton(
                style: TextButton.styleFrom(
                    minimumSize:Size(MediaQuery.of(context).size.width,56),
                    padding: EdgeInsets.all(0),
                    backgroundColor: AppColors().themeDarkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    )
                ),
                onPressed: (){
                  Navigator.push(context,PageTransition(
                      child: CreatingPostScreenNew(),
                      type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                },
                child: AppText(text: 'Let\'s post something',size: 16, style: 'medium', color: AppColors().white).getText(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
