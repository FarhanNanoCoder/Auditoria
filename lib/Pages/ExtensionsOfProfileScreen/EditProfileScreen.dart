import 'dart:io';
import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/EditImageViewer.dart';
import 'package:auditoria/Helping%20Components/ProfileScreenHelpers.dart';
import 'package:auditoria/Helping%20Components/TopAppBar.dart';
import 'package:auditoria/Helping%20Components/ViewModeSelector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget{
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showProgress = false;
  File currentlySelectedImage;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: FutureBuilder(
          future: DatabaseService().getUserFutureData(_auth.currentUser.uid),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: AppColors().themeBrown,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                ),
              );
            }else{
              UserModel _user = UserModel.fromDocumentSnapshot(snapshot.data);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TopAppBar(
                    leftButtonIcon: Icons.arrow_back_ios_rounded,
                    onLeftButtonTap: (){
                      Navigator.pop(context);
                    },
                    pageTitle: 'Profile',
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding:  EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                SizedBox(height: 24,),
                                EditImageViewer(
                                  photoUrl: _user.photoUrl,
                                  onImageChange: (image){
                                    currentlySelectedImage = image;
                                  },
                                  onNull: Icon(Icons.person_outlined,size: 56,color: AppColors().themeDarkBlue,),
                                  tootltip: 'Update profile picture',
                                  height: 196,
                                  width: 196,
                                ),
                                SizedBox(height: 16,),
                                TextFormField(
                                  initialValue: _user.username,
                                  maxLines: 1,
                                  maxLength: 25,
                                  cursorColor: AppColors().themeBrown,
                                  onChanged: (value){_user.username = value.trim();},
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
                                  style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
                                  decoration: AppInputDecoration(label : 'Username').getInputDecoration(),
                                ),
                                SizedBox(height: 16,),
                                TextFormField(
                                  initialValue: _user.artistType,
                                  maxLines: 1,
                                  maxLength: 20,
                                  cursorColor: AppColors().themeBrown,
                                  onChanged: (value){_user.artistType = value.trim();},
                                  textInputAction: TextInputAction.next,
                                  validator: (value){
                                    final validCharacters = RegExp(r'^[A-Za-z]+(?:[ _-][A-Za-z]+)*$');
                                    if(value.trim().length<2){
                                      return 'Too short';
                                    }else if(value.trim().length>20){
                                      return 'Should be under 20 characters';
                                    }else if(!validCharacters.hasMatch(value.trim())){
                                      return 'Should not contain numbers or special characters';
                                    }else{
                                      return null;
                                    }
                                  },
                                  style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
                                  decoration: AppInputDecoration(label: 'Type').getInputDecoration(),
                                ),
                                SizedBox(height: 16,),
                                TextFormField(
                                  initialValue: _user.bio,
                                  maxLines: 4,
                                  maxLength: 150,
                                  cursorColor: AppColors().themeBrown,
                                  onChanged: (value){_user.bio = value.trim();},
                                  textInputAction: TextInputAction.next,
                                  style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
                                  decoration: AppInputDecoration(label: 'Bio',hint: 'Write something about yourself').getInputDecoration(),
                                ),
                                SizedBox(height: 16,),
                                Container(height: 1, color: AppColors().grey200,),
                                SizedBox(height: 16,),
                                Row(
                                  children: [
                                    Icon(Icons.email_outlined,size: 24,color: AppColors().themeDarkBlue,),
                                    SizedBox(width: 16,),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(width: 1,color: AppColors().grey300),),
                                        child: Align(
                                          alignment: Alignment(-1,0),
                                          child: AppText(
                                              text: _user.email,
                                              style: 'regular',size: 16,color: AppColors().themeDarkBlue
                                          ).getText(),
                                        ),
                                      ),),
                                  ],
                                ),
                                ViewModeSelector(
                                  mode: _user.emailViewMode,
                                  onChange: (value){_user.emailViewMode=value;},
                                ),
                                SizedBox(height: 24,),
                                ProfileBirthdayBox(
                                  birthDate: _user.birthDate,
                                  parentContext: context,
                                  getDate: (value){
                                    _user.birthDate = value;
                                  },
                                ),
                                ViewModeSelector(
                                  mode: _user.birthdayViewMode,
                                  onChange: (value){_user.birthdayViewMode=value;},
                                ),
                                SizedBox(height: 24,),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,size: 24,color: AppColors().themeDarkBlue,),
                                    SizedBox(width: 16,),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _user.country,
                                        onChanged: (value){_user.country = value.trim();},
                                        cursorColor: AppColors().themeBrown,
                                        textInputAction: TextInputAction.next,
                                        style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                                        decoration: AppInputDecoration(label: 'Country',hint: 'Bangladesh').getInputDecoration(),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _user.city,
                                        onChanged: (value){_user.city = value.trim();},
                                        cursorColor: AppColors().themeBrown,
                                        textInputAction: TextInputAction.next,
                                        style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                                        decoration: AppInputDecoration(label: 'City',hint: 'Dhaka').getInputDecoration(),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16,),
                                Row(
                                  children: [
                                    SizedBox(width: 40,),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _user.address,
                                        onChanged: (value){_user.address = value.trim();},
                                        cursorColor: AppColors().themeBrown,
                                        textInputAction: TextInputAction.next,
                                        style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                                        decoration: AppInputDecoration(label: 'Address',hint: 'House no :****').getInputDecoration(),
                                      ),
                                    ),
                                  ],
                                ),
                                ViewModeSelector(
                                  mode: _user.livingPlaceViewMode,
                                  onChange: (value){_user.livingPlaceViewMode=value;},
                                ),
                                SizedBox(height: 24,),
                                Row(
                                  children: [
                                    Icon(Icons.phone_outlined,size: 24,color: AppColors().themeDarkBlue,),
                                    SizedBox(width: 16,),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _user.phoneNo,
                                        keyboardType: TextInputType.phone,
                                        onChanged: (value){_user.phoneNo = value.trim();},
                                        cursorColor: AppColors().themeBrown,
                                        textInputAction: TextInputAction.done,
                                        style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                                        decoration: AppInputDecoration(label: 'Phone no',hint: '+88019********').getInputDecoration(),
                                      ),
                                    ),
                                  ],
                                ),
                                ViewModeSelector(
                                  mode: _user.phoneNoViewMode,
                                  onChange: (value){_user.phoneNoViewMode=value;},
                                ),
                                SizedBox(height: 24,),
                                ProfileGenderBox(
                                  gender: _user.gender,
                                  onGenderChange: (value){_user.gender = value;},
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
                                  onPressed: ()async {
                                    if(_formKey.currentState.validate()){
                                      _formKey.currentState.save();
                                     // print(_user);
                                      setState(() {
                                        showProgress = true;
                                      });

                                      if(currentlySelectedImage!=null){
                                        _user.photoUrl = await DatabaseService()
                                            .updateProfileImage(uid: _user.uid,image: currentlySelectedImage);
                                      }
                                     // print(_user.photoUrl);
                                      dynamic result = await DatabaseService().updateUserData(_user);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: AppText(text: 'Save',size: 16, style: 'medium', color: AppColors().white).getText(),
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
                                SizedBox(height: 56,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}