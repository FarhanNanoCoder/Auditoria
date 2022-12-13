import 'dart:async';
import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Pages/EntranceScreens/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../Home.dart';
import 'WelcomeScreen.dart';


class SplashScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SplashScreen();

}

class _SplashScreen extends State<SplashScreen>{
  var presentUser;
  @override
  void initState(){
    super.initState();
    Timer(
      Duration(seconds: 3),
        () async {
        Navigator.pop(context);
        Navigator.push(context,
            PageTransition(
              child: presentUser==null?
            WelcomeScreen(): Home(),
                type: PageTransitionType.fade,duration: Duration(milliseconds: 500),));
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    presentUser =  Provider.of<UserModel>(context);
    return Scaffold(
      backgroundColor: AppColors().white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24,horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 114,),
              SvgPicture.asset('assets/svg/art_museum.svg', width: 303.67,),
              SizedBox(height: 96,),
              AppText(text: 'AUDITORIA',size: 56, style: 'bold', color: AppColors().themeDarkBlue).getText(),
              AppText(text: 'make your art worth',size: 16, style: 'regular', color: AppColors().themeBrown).getText(),
              SizedBox(height: 156,),
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  minHeight: 8,
                  backgroundColor: AppColors().themeBrown,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                ),
              ),
              SizedBox(height: 72,),
            ],
          ),
        ),
      ),
    );
  }
}