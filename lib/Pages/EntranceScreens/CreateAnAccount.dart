import 'package:auditoria/Authentication/AuthService.dart';
import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import '../Home.dart';

class CreateAnAccount extends StatefulWidget{
  final BuildContext parentContext;
  CreateAnAccount({this.parentContext});
  @override
  State<StatefulWidget> createState() =>_CreateAnAccount();

}

class _CreateAnAccount extends State<CreateAnAccount> {
  AuthService _auth = AuthService();

  final _emailController= TextEditingController(),
      _usernameController=TextEditingController(),
      _passwordController=TextEditingController(),
      _confirmPasswordController=TextEditingController();

  bool hidePassword=true,hideConfirmPassword=true;
  bool showProgress = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
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
                      child: AppText(text: 'Create an account',size: 16,style: 'regular',color: AppColors().themeDarkBlue).getText(),),
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
                          SvgPicture.asset('assets/svg/enter_artist.svg',width:124 ,),
                          SizedBox(height: 44,),
                          TextFormField(
                            controller: _usernameController,
                            autofocus: false,
                            cursorColor: AppColors().themeBrown,
                            obscureText: false,
                            style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
                            textInputAction: TextInputAction.next,
                            validator: (value){
                              final validCharacters = RegExp(r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$');
                              if(value.trim().length<2){
                                return 'Username is too short';
                              }else if(value.trim().length>25){
                                return 'Username should be under 25 characters';
                              }else if(!validCharacters.hasMatch(value.trim())){
                                return 'Username should not contain special characters';
                              }else{
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_outline_rounded,color: AppColors().themeDarkBlue,),
                              labelText: 'Username',
                              labelStyle: AppText(style: 'regular',color: AppColors().themeOffBlue,size: 16).getStyle(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().themeDarkBlue, width: 1),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().red, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().red, width: 1),
                              ),
                              errorStyle: AppText(style: 'regular',color: AppColors().red,size: 12).getStyle(),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().themeDarkBlue, width: 1),
                              ),),
                          ),
                          SizedBox(height: 24,),
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
                            textInputAction: TextInputAction.next,
                            validator:(value){
                              if(value.trim().length<6){
                                return 'Too short';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
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
                              ),
                              prefixIcon: Icon(Icons.vpn_key_outlined,color: AppColors().themeDarkBlue,size: 24,),
                              suffixIcon: IconButton(
                                onPressed: (){setState(() {hidePassword =!hidePassword;});},
                                icon: Icon(
                                  hidePassword?Icons.visibility_outlined:Icons.visibility_off_outlined,
                                  color: AppColors().themeDarkBlue,),),),
                          ),
                          SizedBox(height: 24,),
                          TextFormField(
                            controller: _confirmPasswordController,
                            autofocus: false,
                            cursorColor: AppColors().themeBrown,
                            obscureText: hideConfirmPassword,
                            style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
                            validator: (value){
                              if(_passwordController.text!=null &&
                                  _confirmPasswordController.text!= _passwordController.text){
                                return 'Doesn\'t match with the password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Confirm password',
                              labelStyle: AppText(style: 'regular',color: AppColors().themeOffBlue,size: 16).getStyle(),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                BorderSide(color: AppColors().themeDarkBlue, width: 1),
                              ),
                              errorStyle: AppText(style: 'regular',color: AppColors().red,size: 12).getStyle(),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().red, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: AppColors().red, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                BorderSide(color: AppColors().themeDarkBlue, width: 1),
                              ),
                              prefixIcon: Icon(Icons.vpn_key_outlined,color: AppColors().themeDarkBlue,size: 24,),
                              suffixIcon: IconButton(
                                onPressed: (){setState(() {hideConfirmPassword =!hideConfirmPassword;});},
                                icon: Icon(
                                  hideConfirmPassword?Icons.visibility_outlined:Icons.visibility_off_outlined,
                                  color: AppColors().themeDarkBlue,),),),
                          ),
                          SizedBox(height: 36,),
                          AppText(text: 'Please be sensible when providing your '
                              'information. Any suspicious or mal-information can '
                              'result in permanent deactivation of your account.',
                              size: 14,
                              color: AppColors().themeOffBlue,
                          ).getText(),
                          SizedBox(height: 16,),
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
                                UserModel result = await _auth.registerWithEmailAndPassword(
                                  email: _emailController.text.trim(),password: _passwordController.text);
                                if(result==null){
                                  print("something wrong happened");
                                  setState(() {
                                    showProgress = false;
                                  });
                                }else{
                                  result.username = _usernameController.text.trim();
                                  await DatabaseService().createUserdata(result);
                                  print(result);

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
                            child: AppText(text: 'Create an account',size: 16, style: 'medium', color: AppColors().white).getText(),
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