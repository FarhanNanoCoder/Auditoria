import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Pages/MainScreens/ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';

// ignore: must_be_immutable
class ProfileTabFollowings extends StatefulWidget{
  String uid;
  bool isViewAs;

  ProfileTabFollowings({this.uid, this.isViewAs});

  @override
  _ProfileTabFollowings createState() => _ProfileTabFollowings();
}

class _ProfileTabFollowings extends State<ProfileTabFollowings> {

  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.clear();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: DatabaseService().allFollowingsCollection.doc(widget.uid).collection('userFollowings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Followings followingsModel = Followings.fromDocumentSnapshot(snapshot.data);
            QuerySnapshot followingsCollection = snapshot.data;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                      text: 'Persons you are following', size: 12,
                      style: 'regular', color: AppColors().themeOffBlue).getText(),
                  SizedBox(height: 16,),
                  Row(
                    children: [
                      Container(
                        height: 56,
                        width: 72,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors().themeBrown),
                        child: Center(
                          child: AppText(text: followingsCollection.size.toString(),
                              size: 16, style: 'regular', color: AppColors().white).getText(),
                        ),
                      ),
                      SizedBox(width: 8,),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: TextFormField(
                            controller: searchController,
                            maxLines: 1,
                            cursorColor: AppColors().themeBrown,
                            textInputAction: TextInputAction.done,
                            style: AppText(style: 'regular', color: AppColors().themeDarkBlue, size: 16).getStyle(),
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: AppInputDecoration(
                                hint: 'Search for a person',
                                prefixIcon: Icons.search_outlined,
                                prefixIconColor: AppColors().grey400,
                                suffixIcon: Icons.close_rounded,
                                suffixIconColor: AppColors().grey400,
                                onSuffixButtonClick: () {
                                  setState(() {
                                    FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                    searchController.text = '';
                                  });
                                }).getInputDecoration(),),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16,),
              FutureBuilder(
                future: DatabaseService().getUserFollowingsAsUserModelListAsFuture(followingsCollection, searchController.text.trim()??''),
                builder: (context,followingsSnapshot){
                  if(!followingsSnapshot.hasData ){
                    if(followingsCollection.size==0){
                      return Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 72,),
                                WebsafeSvg.asset('assets/svg/following_.svg', width:MediaQuery.of(context).size.width*0.6 ),
                                SizedBox(height: 24,),
                                AppText(text: 'No Followings').getText()
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: SizedBox(
                        height: 36,
                        width: 36,
                        child: CircularProgressIndicator(
                          backgroundColor: AppColors().themeBrown,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                        ),
                      ),
                    );
                  }else{
                    List<UserModel> followings = followingsSnapshot.data;
                    print('length of followers :'+followings.length.toString());

                    if(followings==null || followings.length==0){
                      return Center(
                        child: AppText(text: 'No user found',
                            size: 16, style: 'regular', color: AppColors().themeDarkBlue).getText(),);
                    }else{
                      return Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: followings.length,
                          itemBuilder: (context,index){
                            String username = followings[index].username,artistType = followings[index].artistType,
                                photoUrl=followings[index].photoUrl;
                            return InkWell(
                              onTap: (){
                                Navigator.push(context,PageTransition(
                                    child: ProfileScreen(uid: followings[index].uid,isViewAs: true,),
                                    type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 500)));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 72,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,height: 48,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(24),
                                              color: AppColors().white,
                                              border: photoUrl==null?Border.all(width: 1,color: AppColors().grey200):null,
                                            ),
                                            child: photoUrl==null?
                                            Icon(Icons.person_outlined,size: 24, color: AppColors().themeDarkBlue,):
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(24),
                                              child: Image.network(photoUrl,
                                                loadingBuilder: (context,child,progress){
                                                  return progress==null?child:Center(
                                                    child: SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        backgroundColor: AppColors().themeBrown,
                                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16,),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                AppText(text: username,style: 'regular',color: AppColors().themeDarkBlue,size: 16).getText(),
                                                SizedBox(height: 4,),
                                                AppText(text: artistType,style: 'regular',color: AppColors().themeDarkBlue,size: 12).getText(),
                                              ],
                                            ),
                                          ),
                                          followings[index].uid!=FirebaseAuth.instance.currentUser.uid?Container(
                                            height: 32,
                                            width: 48,
                                            decoration: BoxDecoration(
                                                color: AppColors().white,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: AppColors().themeBrown,width: 1)
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(4) ),
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                onTap: (){
                                                  DatabaseService().updateFollowingsAndFollowers(
                                                      uid: followings[index].uid,);
                                                  setState(() {});
                                                },
                                                child: Icon(Icons.how_to_reg_outlined,size: 18,color: AppColors().themeBrown,),
                                              ),
                                            ),
                                          ):SizedBox(width: 0,),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      width: MediaQuery.of(context).size.width,
                                      color: AppColors().grey100,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }
                },
              ),
                ],
              ),
            );
          } else {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 72,),
                    WebsafeSvg.asset('assets/svg/following_.svg', width:MediaQuery.of(context).size.width*0.6 ),
                    SizedBox(height: 24,),
                    AppText(text: 'No Followings').getText()
                  ],
                ),
              ),
            );
          }
        });
  }
}