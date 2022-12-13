import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Pages/ExtensionOfSettings/AboutUs.dart';
import 'package:auditoria/Pages/ExtensionOfSettings/NotificationScreen.dart';
import 'package:auditoria/Pages/ExtensionOfSettings/ReportProblemScreen.dart';
import 'package:auditoria/Pages/ExtensionOfSettings/SavePostsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatelessWidget{

  int _notifications=0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 24,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24,),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    SizedBox(
                      width: 186, height: 48,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 24,),
                            side: BorderSide(
                              color: AppColors().themeDarkBlue,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                            backgroundColor: AppColors().white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            )
                        ),
                        onPressed: (){
                          Navigator.push(context,PageTransition(
                              child: NotificationScreen(recentNotifications: _notifications,),
                              type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.notifications_none_outlined,color: AppColors().themeDarkBlue,size: 24,),
                            SizedBox(width: 16,),
                            AppText(text: 'Notifications',style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16,),
                    StreamBuilder(
                      stream: DatabaseService().getUserLiveDataAsStream(FirebaseAuth.instance.currentUser.uid),
                      builder:(context,snapshot){
                        if(snapshot.hasData){
                          int recentNotifications = UserModelLiveData.fromDocumentSnapshot(snapshot.data).recentNotifications;
                          _notifications = recentNotifications;
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: AppColors().themeBrown
                            ),
                            child: Center(
                              child: AppText(
                                text: recentNotifications<100?recentNotifications.toString():'99+',
                                style: 'regular',
                                color: AppColors().white,
                                size: 16,
                              ).getText(),
                            ),
                          );
                        }else{
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: AppColors().themeBrown
                            ),
                            child: Center(
                              child: AppText(
                                text: '0',
                                style: 'regular',
                                color: AppColors().white,
                                size: 16,
                              ).getText(),
                            ),
                          );
                        }
                    }
                    ),
                  ],
                ),
              ),
              SizedBox(height: 56,),
              Row(
                children: [
                  WebsafeSvg.asset('assets/svg/notification_.svg',width: MediaQuery.of(context).size.width*0.3),
                  SizedBox(width: 24,),
                  Expanded(
                    child: AppText(text: 'Explore your notifications,'
                        ' achievements and other options',
                      style: 'regular', size: 14,color: AppColors().themeDarkBlue).getText(),
                  ),
                ],
              ),
              SizedBox(height: 44,),
              TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24,),
                    minimumSize: Size.fromHeight(56),
                    side: BorderSide(
                      color: AppColors().grey200,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                    backgroundColor: AppColors().white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    )
                ),
                onPressed: (){
                  Navigator.push(context,PageTransition(
                      child: SavedPostsScreen(),
                      type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                },
                child: Row(
                  children: [
                    Icon(Icons.bookmark_outline_rounded,color: AppColors().themeDarkBlue,size: 24,),
                    SizedBox(width: 16,),
                    AppText(text: 'Saved posts',style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
                  ],
                ),
              ),
              SizedBox(height: 24,),
              TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24,),
                    minimumSize: Size.fromHeight(56),
                    side: BorderSide(
                      color: AppColors().grey200,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                    backgroundColor: AppColors().white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    )
                ),
                onPressed: (){
                  Navigator.push(context,PageTransition(
                      child: ReportProblemScreen(),
                      type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                },
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,color: AppColors().themeDarkBlue,size: 24,),
                    SizedBox(width: 16,),
                    AppText(text: 'Report a problem',style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
                  ],
                ),
              ),
              SizedBox(height: 24,),
              TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24,),
                    minimumSize: Size.fromHeight(56),
                    side: BorderSide(
                      color: AppColors().grey200,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                    backgroundColor: AppColors().white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    )
                ),
                onPressed: (){
                  Navigator.push(context,PageTransition(
                      child: AboutUs(),
                      type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                },
                child: Row(
                  children: [
                    Icon(Icons.subtitles_outlined,color: AppColors().themeDarkBlue,size: 24,),
                    SizedBox(width: 16,),
                    AppText(text: 'About us',style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
                  ],
                ),
              ),
              SizedBox(height: 24,),
            ],
          ),
        ),
      ),
    );
  }
}