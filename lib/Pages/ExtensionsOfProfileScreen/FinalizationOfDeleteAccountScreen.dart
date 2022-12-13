import 'package:auditoria/Authentication/AuthService.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Pages/EntranceScreens/WelcomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';

class FinalizationOfDeleteAccountScreen extends StatefulWidget{
  final UserCredential result;

  FinalizationOfDeleteAccountScreen({this.result});

  @override
  _FinalizationOfDeleteAccountScreenState createState() => _FinalizationOfDeleteAccountScreenState();
}

class _FinalizationOfDeleteAccountScreenState extends State<FinalizationOfDeleteAccountScreen> {
  bool showProgress = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 24,vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WebsafeSvg.asset('assets/svg/data_processing_.svg',width: MediaQuery.of(context).size.width*0.7),
              SizedBox(height: 72,),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize:Size(MediaQuery.of(context).size.width,56),
                  padding: EdgeInsets.all(0),
                  backgroundColor: AppColors().themeDarkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    showProgress = true;
                  });
                  await DatabaseService().deleteUser(widget.result.user.uid).whenComplete(() async {
                    await Future.delayed(Duration(seconds: 5));
                    await AuthService().deleteUserFromAuth(userCredential: widget.result);
                    Navigator.pop(context);
                    Navigator.push(context,
                        PageTransition(
                          child: WelcomeScreen(),
                          type: PageTransitionType.fade,duration: Duration(milliseconds: 500),));
                  });
                },
                child: AppText(text: 'Delete all data',size: 16, style: 'medium', color: AppColors().white).getText(),
              ),
              SizedBox(height: 24,),
              showProgress?SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  minHeight: 8,
                  backgroundColor: AppColors().themeBrown,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                ),
              ) :SizedBox(height: 8,),
            ],
          ),
        ),
      ),
    );
  }
}