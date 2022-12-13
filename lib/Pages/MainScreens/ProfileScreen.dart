import 'dart:async';
import 'dart:ui';
import 'package:auditoria/Authentication/AuthService.dart';
import 'package:auditoria/Data%20Models/PostModel.dart';
import 'package:auditoria/Helping%20Components/Converters.dart';
import 'package:auditoria/Helping%20Components/ProfileScreenHelpers.dart';
import 'package:auditoria/Helping%20Components/TopAppBar.dart';
import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppBottomSheetAndDialog.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Pages/EntranceScreens/WelcomeScreen.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/DeleteAccountScreen.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/EditProfileScreen.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/ProfileTabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  BuildContext parentContext;
  final bool isViewAs;
  final String uid;
  ProfileScreen({this.isViewAs,this.uid,this.parentContext});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{

  DocumentSnapshot documentSnapshot;

   Future<bool>isUserFound()async{
   documentSnapshot = await DatabaseService().userCollections.doc(widget.uid).get();
   if(documentSnapshot.exists){
     return true;
   }else{
     return false;
   }
  }

  signOut()async{
    Navigator.pop(context);
    AuthService().signOut();
    Navigator.push(context,PageTransition(
    child: WelcomeScreen(),
    type: PageTransitionType.rightToLeft,duration: Duration(milliseconds: 500)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: FutureBuilder(
          future: isUserFound(),
          builder: (context,AsyncSnapshot<bool> checkingSnapshot){
            if(!checkingSnapshot.hasData ){
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: AppColors().themeBrown,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                ),
              );
            }else{
              if(!checkingSnapshot.data){
                return Center(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,size: 56,color: AppColors().themeOffBlue,),
                    SizedBox(height: 24,),
                    AppText(text: 'Opps! user not found',).getText(),
                  ],
                ));
              }
              return StreamBuilder(
                stream : DatabaseService().getUserStreamData(widget.uid),//_fetchUserData(),
                // initialData: documentSnapshot,
                builder: (context,snapshot){
                  if(!(snapshot.connectionState == ConnectionState.done) && (snapshot.hasError || !snapshot.hasData) ){
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: AppColors().themeBrown,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                      ),
                    );
                  }else{
                    UserModel _user = UserModel.fromDocumentSnapshot(snapshot.data);

                    List<String> details = [_user.birthDate,_user.email,_user.phoneNo,
                      getLivingPlace(city: _user.city,country: _user.country)];
                    List<String> viewModes =[_user.birthdayViewMode,_user.emailViewMode,
                      _user.phoneNoViewMode,_user.livingPlaceViewMode];

                    double count =0,privateFields=0;
                    for(int i=0;i<details.length;i++){
                      if(details[i]!=null && details[i].isNotEmpty){
                        count++;
                        if(viewModes[i]!='Public'){privateFields++;}
                      }
                    }
                    double detailsViewLength = widget.isViewAs?count-privateFields:count;
                    int bioLength = _user.bio!=null?_user.bio.length~/40:0;
                    int extra = (_user.bio==null || _user.bio.isEmpty)&&!widget.isViewAs?124:0;

                    double expandedHeight = 136+16+44+24+(bioLength*24)+24+36+(detailsViewLength*(widget.isViewAs?44:56))+extra;

                    return Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          height: 56,
                          child: Stack(
                            children: [
                              widget.isViewAs?Align(
                                alignment: Alignment(-1,0),
                                child: IconButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.arrow_back_ios_rounded),
                                  iconSize: 24, color: AppColors().themeDarkBlue,
                                ),
                              ):SizedBox(width: 24,height: 24,),
                              widget.isViewAs?Align(
                                alignment: Alignment(1,0),
                                child: Container(
                                  height: 56,
                                  width: 56,
                                  child: Material(
                                    color: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(28) ),
                                    clipBehavior: Clip.antiAlias,
                                    child: StreamBuilder(
                                        stream: DatabaseService().allFollowingsCollection
                                            .doc(FirebaseAuth.instance.currentUser.uid)
                                            .collection('userFollowings').doc(widget.uid).snapshots(),

                                        builder: (context, followingsSnapshot) {
                                          if(!followingsSnapshot.hasData){
                                            return InkWell(
                                              onTap: (){
                                                if(FirebaseAuth.instance.currentUser.uid != widget.uid){
                                                  DatabaseService().updateFollowingsAndFollowers(
                                                      uid: widget.uid);
                                                }
                                              },
                                              child: Icon(Icons.person_add_alt,size: 24,color: AppColors().themeOffBlue,),
                                            );
                                          }else{
                                            DocumentSnapshot doc = followingsSnapshot.data;
                                            return InkWell(
                                              onTap: (){
                                                if(FirebaseAuth.instance.currentUser.uid != widget.uid){
                                                  DatabaseService().updateFollowingsAndFollowers(
                                                      uid: widget.uid);
                                                }
                                              },
                                              child: Icon(doc.exists?Icons.how_to_reg_outlined:
                                              Icons.person_add_alt,size: 24,color:
                                              doc.exists?AppColors().themeBrown:AppColors().themeOffBlue,),
                                            );
                                          }
                                        }
                                    ),
                                  ),
                                ),
                              ): Align(
                                alignment: Alignment(1,0),
                                child: IconButton(
                                  onPressed: (){
                                    AppBottomSheet(
                                      parentContext: context,
                                      buttonNames: ['View as','Edit profile','Delete account','Log out'],
                                      onButtonTap: (index){
                                        Widget _pageToGo;
                                        if(index == 0){
                                          _pageToGo = ProfileScreen(isViewAs: true,uid: widget.uid,);
                                        }else if(index==1){
                                          _pageToGo = EditProfileScreen();
                                        }else if(index == 2){
                                          _pageToGo = DeleteAccountScreen(parentContext: widget.parentContext,email: _user.email,);
                                        }else if(index == 3 ){
                                          // Navigator.pop(context);
                                          signOut();
                                          return;
                                        }
                                        Navigator.push(context,PageTransition(
                                            child:_pageToGo,
                                            type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 500)));
                                        // print(index);
                                      },
                                      icons: [
                                        Icons.remove_red_eye_outlined,
                                        Icons.edit_outlined,
                                        Icons.delete_outline_rounded,
                                        Icons.logout,
                                      ],
                                    ).viewModalBottomSheet();
                                  },
                                  icon: Icon(Icons.notes_rounded),
                                  iconSize: 24,
                                  color: AppColors().themeDarkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverAppBar(
                                leading: SizedBox(height: 24,),
                                expandedHeight: expandedHeight,
                                backgroundColor: AppColors().white,
                                flexibleSpace: FlexibleSpaceBar(
                                  background: SingleChildScrollView(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.symmetric(horizontal: 24),
                                      color: AppColors().white,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 16,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: 136,
                                                height: 136,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  color: AppColors().white,
                                                  border: Border.all(width: 1,color: AppColors().grey200),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: _user.photoUrl==null?
                                                  Icon(
                                                    Icons.person_outlined,size: 48, color: AppColors().themeOffBlue,
                                                  ):Image.network(_user.photoUrl,
                                                    loadingBuilder: (context,child,progress){
                                                      return progress==null?child:Center(
                                                        child: SizedBox(
                                                          width: 72,
                                                          height: 72,
                                                          child: CircularProgressIndicator(
                                                            backgroundColor: AppColors().themeBrown,
                                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),),
                                              SizedBox(
                                                  height: 136,
                                                  width: MediaQuery.of(context).size.width-(48+136+24),
                                                  child: StreamBuilder(
                                                    stream: DatabaseService().getUserLiveDataAsStream(_user.uid),
                                                    builder: (context,liveDataSnapshot){

                                                      if(liveDataSnapshot.hasData){
                                                        UserModelLiveData liveData = UserModelLiveData.fromDocumentSnapshot(liveDataSnapshot.data);
                                                        return Column(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 24),
                                                              width: MediaQuery.of(context).size.width,//-(48+136+24),
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(4),
                                                                color: AppColors().white,
                                                                border: Border.all(width: 1.0,color: AppColors().grey200),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Icon(Icons.favorite,color: AppColors().themeBrown,size: 24,),
                                                                  SizedBox(width: 12,),
                                                                  AppText(text: liveData.totalLikes.toString(),style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
                                                                  Spacer(),
                                                                  Icon(Icons.wysiwyg,color: AppColors().themeBrown,size: 24,),
                                                                  SizedBox(width: 12,),
                                                                  AppText(text: liveData.totalPosts.toString(),style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
                                                                ],
                                                              ),
                                                            ),
                                                            RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                    TextSpan(text: 'Followers : ',
                                                                        style: AppText(style: 'regular',size: 14,color: AppColors().themeDarkBlue).getStyle()),
                                                                    TextSpan(text: liveData.followers.toString(),
                                                                        style:AppText(style: 'bold',size: 16,color: AppColors().themeBrown).getStyle() ),
                                                                  ]
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }else{
                                                        return AppText(text: 'loading....',
                                                            style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText();
                                                      }
                                                    },
                                                  )
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16,),
                                          AppText(text:_user.username,style: 'semibold',size: 18,color: AppColors().themeDarkBlue).getText(),
                                          AppText(text:_user.artistType,style: 'regular',size: 14,color: AppColors().themeBrown).getText(),
                                          SizedBox(height: 16,),
                                          (_user.bio!=null && _user.bio.isNotEmpty)?AppText(
                                              text: _user.bio,
                                              style: 'regular',size: 16,color: AppColors().themeDarkBlue
                                          ).getText()
                                              :widget.isViewAs?SizedBox(height: 0,):Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: 124,
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  WebsafeSvg.asset('assets/svg/addbio_.svg',height: 116),
                                                  SizedBox(width: 16,),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: AppText(
                                                            text: 'Add some word that describes you and your artist platform to everyone.',
                                                            style: 'regular',size: 14,color: AppColors().themeDarkBlue,
                                                          ).getText(),
                                                        ),
                                                        TextButton(
                                                          style: TextButton.styleFrom(
                                                              minimumSize:Size(144,26),
                                                              padding: EdgeInsets.all(0),
                                                              backgroundColor: AppColors().themeDarkBlue,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(4),
                                                              )
                                                          ),
                                                          onPressed: (){
                                                            Navigator.push(context,PageTransition(
                                                                child: EditProfileScreen(),
                                                                type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 500)));
                                                          },
                                                          child: AppText(text: 'Add your bio, now!',size: 12, style: 'medium', color: AppColors().white).getText(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8,),
                                          Container(
                                            height: 1,
                                            color: AppColors().grey200,
                                          ),
                                          SizedBox(height: 16,),
                                          ProfileDetailsViewer(
                                            isViewAs:widget.isViewAs,
                                            iconData: [
                                              Icons.cake_outlined,Icons.email_outlined,
                                              Icons.phone_outlined,Icons.location_on_outlined,
                                            ],
                                            details: details,
                                            viewMode: viewModes,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SliverFillRemaining(
                                hasScrollBody: true,
                                child: ProfileTabs(uid: widget.uid,isViewAs: widget.isViewAs,),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}