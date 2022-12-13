import 'package:auditoria/Authentication/AuthService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/Toast.dart';
import 'package:auditoria/Pages/EntranceScreens/ForgotPasswordScreen.dart';
import 'package:auditoria/Pages/Home.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';


class SignInScreen extends StatefulWidget{
  final BuildContext parentContext;
  SignInScreen({this.parentContext});
  @override
  State<StatefulWidget> createState() => _SignInScreen();

}

class _SignInScreen extends State<SignInScreen>{
  AuthService _auth = AuthService();
  final _emailController= TextEditingController(),
      _passwordController=TextEditingController();
  bool hidePassword=true;
  bool showProgress = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
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
                        child: AppText(text: 'Sign in',size: 16,style: 'regular',color: AppColors().themeDarkBlue).getText(),),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 16,),
                          WebsafeSvg.asset('assets/svg/flowers_login.svg',width:204 ,),
                          SizedBox(height: 56,),
                          TextFormField(
                            controller: _emailController,
                            autofocus: false,
                            cursorColor: AppColors().themeBrown,
                            obscureText: false,
                            style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
                            textInputAction: TextInputAction.next,
                            validator: (value)=>EmailValidator.validate(
                              _emailController.text.trim())?null:'Invalid email',
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.mail_outline_rounded,color: AppColors().themeDarkBlue,),
                              labelText: 'Email',
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
                          SizedBox(height: 24,),
                          TextFormField(
                            controller: _passwordController,
                            autofocus: false,
                            cursorColor: AppColors().themeBrown,
                            obscureText: hidePassword,
                            style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: AppText(style: 'regular',color: AppColors().themeOffBlue,size: 16).getStyle(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                BorderSide(color: AppColors().themeDarkBlue, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                BorderSide(color: AppColors().themeDarkBlue, width: 1),
                              ),
                              prefixIcon: Icon(Icons.vpn_key_outlined,color: AppColors().themeDarkBlue,size: 24,),
                              suffixIcon: IconButton(
                                onPressed: (){setState(() {hidePassword =!hidePassword;});},
                                icon: Icon(
                                  hidePassword?Icons.visibility_outlined:Icons.visibility_off_outlined,
                                  color: AppColors().themeDarkBlue,),),),
                          ),
                          SizedBox(height: 16,),
                          InkWell(
                            onTap: (){
                             // Navigator.pop(context);
                              Navigator.push(context,
                              PageTransition(child: ForgotPasswordScreen(),
                                  type: PageTransitionType.rightToLeft,duration: Duration(milliseconds: 500)));
                            },
                            child: AppText(text: 'Forgot password',size: 16, style: 'medium', color: AppColors().themeDarkBlue).getText(),
                          ),
                          SizedBox(height: 36,),
                          TextButton(
                            style: TextButton.styleFrom(
                                minimumSize:Size(MediaQuery.of(context).size.width,56),
                                padding: EdgeInsets.all(0),
                                backgroundColor: AppColors().themeDarkBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                )
                            ),
                            onPressed: () async {
                              if(_formKey.currentState.validate()){
                                _formKey.currentState.save();
                                setState(() {
                                  showProgress = true;
                                });
                                dynamic result = await _auth.signInWithEmailAndPassword(
                                    email: _emailController.text.trim(),password: _passwordController.text);
                                if(result!=true){
                                  setState(() {
                                    showProgress = false;
                                  });
                                  Toast(context: context).showTextToast(result.toString());
                                }else{
                                  Navigator.pop(widget.parentContext);
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                  PageTransition(
                                    child: Home(),
                                    type: PageTransitionType.rightToLeft, duration: Duration(milliseconds: 500),
                                  ));
                                }
                              }
                            },
                            child: AppText(text: 'Sign in',size: 16, style: 'medium', color: AppColors().white).getText(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}