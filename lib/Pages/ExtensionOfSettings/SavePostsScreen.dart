import 'package:auditoria/Data%20Models/PostModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/TopAppBar.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/ShowSpecificPostScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class SavedPostsScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8,),
          child: Column(
            children: [
              TopAppBar(
                leftButtonIcon: Icons.arrow_back_ios_rounded,
                onLeftButtonTap: (){
                  Navigator.pop(context);
                },
                pageTitle: 'Saved',
              ),
              Expanded(
                child: FutureBuilder(
                  future: DatabaseService().getUserSavedPostsAsFutureAsPostModelList(FirebaseAuth.instance.currentUser.uid),
                  builder: (context,querySnapshot){
                    if(querySnapshot.hasData ){
                      List<PostModel> savedPosts = querySnapshot.data;
                      if(savedPosts.length==0){
                        return Center(
                          child: AppText(text: 'Nothing saved yet',
                              style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
                        );
                      }else{
                        return GridView.builder(
                          itemCount: savedPosts.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                              childAspectRatio: 1.0
                          ),
                          itemBuilder: (context,index){
                            return InkWell(
                              onTap: (){
                                Navigator.push(context,PageTransition(
                                    child: ShowSpecificPostScreen(
                                      startingIndex: index,
                                      postModelLists: savedPosts,
                                      isViewAs: true,
                                      uid: FirebaseAuth.instance.currentUser.uid,
                                    ),
                                    type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: AppColors().grey200,
                                  border: Border.all(width: 1,color: AppColors().grey200),),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(savedPosts[index].imageUrl,fit: BoxFit.cover,
                                    loadingBuilder: (context,child,progress){
                                      return progress==null?child:Center(
                                        child: SizedBox(
                                          width: 56, height: 56,
                                          child: CircularProgressIndicator(
                                            backgroundColor: AppColors().themeBrown,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),),),);},),),
                              ),
                            );},
                        );
                      }
                      return null;

                    }else{
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: AppColors().themeBrown,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}