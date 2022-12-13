import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Pages/EntranceScreens/CreateAnAccount.dart';
import 'package:auditoria/Pages/EntranceScreens/SignInScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';

class WelcomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24,horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 100,),
              SvgPicture.asset('assets/svg/both_sides.svg',width: 224,),
              SizedBox(height: 16,),
              AppText(text: 'Welcome',style: 'regular',color: AppColors().themeBrown,size:12 ).getText(),
              SizedBox(height: 24,),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                child: AppText(text: 'AUDITORIA',size: 56, style: 'bold', color: AppColors().themeDarkBlue).getText(),),
              AppText(
                  text: 'Auditoria is a complete online interactive platform for'
                      ' artist to showcase their work, get support and inspiration '
                      'from others. Art enthusiast people can find their need '
                      'and also can hire any artist.',
                  style: 'regular',color: AppColors().themeDarkBlue,size:16 ).getText(),
              SizedBox(height: 96,),
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
                  Navigator.push(context,
                      PageTransition(child: SignInScreen(parentContext: context,),
                        type: PageTransitionType.rightToLeft,duration: Duration(milliseconds: 500),));
                },
                child: AppText(text: 'Sign in',size: 16, style: 'medium', color: AppColors().white).getText(),
              ),
              SizedBox(height: 24,),
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
                  Navigator.push(context,
                      PageTransition(child: CreateAnAccount(parentContext: context,),
                        type: PageTransitionType.rightToLeft,duration: Duration(milliseconds: 500),));
                },
                child: AppText(text: 'Create an account',size: 16, style: 'medium', color: AppColors().white).getText(),
              ),
            ],
          ),
        ),
      ),
    );
  }

}