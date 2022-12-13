import 'dart:ui';
import 'package:auditoria/Authentication/AuthService.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppBottomSheetAndDialog.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/FeedbackTypeDataCollectingScreen.dart';
import 'package:auditoria/Helping%20Components/Toast.dart';
import 'package:auditoria/Helping%20Components/TopAppBar.dart';
import 'package:auditoria/Pages/EntranceScreens/WelcomeScreen.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/FinalizationOfDeleteAccountScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class DeleteAccountScreen extends StatefulWidget{
  final BuildContext parentContext;
  String email;

  DeleteAccountScreen({this.parentContext,this.email});

  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final passwordController = TextEditingController();
  bool showProgress=false;
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
  showAuthenticationDialog({BuildContext context}){
    showAppDialog(context: context,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24,horizontal: 24),
          width: MediaQuery.of(context).size.width,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors().white,
          ),
          child: Column(
            children: [
              AppText(text: 'Enter your password to authenticate', style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
              SizedBox(height: 24,),
              TextFormField(
                obscureText: true,
                controller: passwordController,
                cursorColor: AppColors().themeBrown,
                textInputAction: TextInputAction.next,
                style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                decoration: AppInputDecoration(label: ' Password').getInputDecoration(),
              ),
              SizedBox(height: 44,),
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
                  Navigator.pop(context);
                  setState(() {
                    showProgress=true;
                  });
                  deleteUser();
                },
                child: AppText(text: 'Proceed',size: 16, style: 'medium', color: AppColors().white).getText(),
              ),
            ],
          ),
        ),
    );
  }

  void deleteUser()async{
    UserCredential result = await AuthService().reAuthenticateUser(password: passwordController.text.trim());
    if(result==null){
      setState(() {
        showProgress = false;
      });
      Toast(context: context).showTextToast('Invalid password');
    }else{
      Navigator.pop(widget.parentContext);
      Navigator.pop(context);
      Navigator.push(context,
          PageTransition(
            child: FinalizationOfDeleteAccountScreen(result: result),
            type: PageTransitionType.fade,duration: Duration(milliseconds: 200),));
    }
  }

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
                        svgPath: 'assets/svg/delete_.svg',
                        title: 'Will you tell us your reason for leaving?',
                        hint: 'Write your reason...',
                        buttonText: 'Delete account',
                        onSubmit: (feedbackText)async {
                          setState(() {
                            showProgress = true;
                          });
                          await DatabaseService().accountDeleteReason(
                            cause: feedbackText,).whenComplete((){
                            setState(() {
                              showProgress = false;
                            });
                            showAuthenticationDialog(context: context);
                          });
                        },
                        extraText: 'There is no way getting back your data once you delete your account',
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

