import 'package:auditoria/Authentication/AuthService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/Toast.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';

class ForgotPasswordScreen extends StatefulWidget{
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthService _auth = AuthService();
  bool showProgress = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: GestureDetector(
          onTap: (){
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 72,
                  child: Stack(
                    children: [
                      Center(
                        child: AppText(text: 'Forgot password',size: 16,style: 'regular',color: AppColors().themeDarkBlue).getText(),),
                      Positioned(
                        top: 24,
                        left: 24,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: IconButton(
                            icon:Icon(Icons.arrow_back_ios_rounded,size: 24,),
                            color: AppColors().grey900,
                            padding: EdgeInsets.zero,
                            tooltip: 'Go back to welcome screen',
                            onPressed:(){
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 16,),
                        WebsafeSvg.asset('assets/svg/email_man.svg',width: 236),
                        SizedBox(height: 48,),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _emailController,
                            autofocus: false,
                            cursorColor: AppColors().themeBrown,
                            obscureText: false,
                            style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
                            textInputAction: TextInputAction.next,
                            validator: (value)=>EmailValidator.validate(
                                _emailController.text.trim())?null:'Invalid email',
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.admin_panel_settings_outlined,color: AppColors().themeDarkBlue,),
                              labelText: 'Registered email',
                              labelStyle: AppText(style: 'regular',color: AppColors().themeOffBlue,size: 16).getStyle(),
                              errorStyle: AppText(style: 'regular',color: AppColors().red,size: 12).getStyle(),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().red, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().red, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().themeDarkBlue, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().themeDarkBlue, width: 1),
                              ),),
                          ),
                        ),
                        SizedBox(height: 16,),
                        AppText(
                          text: 'A verification link will be sent to your email.'
                              ' Use it to verify yourself and continue.',
                          style: 'regular',size: 14,color: AppColors().themeOffBlue,
                        ).getText(),
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
                          onPressed: ()async{
                            if(_formKey.currentState.validate()){
                              _formKey.currentState.save();
                              setState(() {
                                showProgress = true;
                              });
                              dynamic result = _auth.passwordReset(email: _emailController.text.trim());
                              if(result==true){
                                Toast(context: context).showTextToast('Password reset link sent tot your email');
                                await Future.delayed(Duration(milliseconds: 1000));
                                Navigator.pop(context);
                              }else{
                                Toast(context: context).showTextToast('Invalid email');
                                setState(() {
                                  showProgress =false;
                                });
                              }
                            }
                          },
                          child: AppText(text: 'Verify yourself',size: 16, style: 'medium', color: AppColors().white).getText(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}