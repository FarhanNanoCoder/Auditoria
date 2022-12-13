import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/FeedbackTypeDataCollectingScreen.dart';
import 'package:auditoria/Helping%20Components/Toast.dart';
import 'package:auditoria/Helping%20Components/TopAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportProblemScreen extends StatefulWidget{

  @override
  _ReportProblemScreenState createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {

  bool showProgress=false;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: (){
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },

        child: Scaffold(
          backgroundColor: AppColors().white,
          body: Column(
            children: [
              TopAppBar(
                onLeftButtonTap: (){
                  Navigator.pop(context);
                },
                leftButtonIcon: Icons.arrow_back_ios_rounded,
                pageTitle: 'Delete account',
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FeedBackTypeDataCollectingScreen(
                        svgPath: 'assets/svg/data_processing_.svg',
                        title: 'Describe your problem',
                        hint: 'Write your problem...',
                        buttonText: 'Report problem',
                        onSubmit: (feedbackText)async {
                          setState(() {
                            showProgress = true;
                          });
                          await DatabaseService()
                              .reportProblem(uid: FirebaseAuth.instance.currentUser.uid,
                              problem: feedbackText).whenComplete((){
                                Toast(context: context).showTextToast('Problem reported');
                                Navigator.pop(context);});

                        },
                        extraText: '* The solving procedure may take a while',
                      ),
                      SizedBox(height: 8,),
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
            ],
          ),
        ),
      ),
    );
  }
}