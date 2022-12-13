import 'package:auditoria/Data%20Models/PostModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/ShowSpecificPostScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';


class ProfileTabPosts extends StatelessWidget {
  String uid;
  bool isViewAs;
  ProfileTabPosts({this.uid,this.isViewAs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white,
      body: FutureBuilder(
        future: DatabaseService().getUserAllPostsAsPostModelList(uid),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            if(snapshot.connectionState==ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: AppColors().themeBrown,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                ),
              );
            }
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WebsafeSvg.asset('assets/svg/blank_canvas.svg', width:MediaQuery.of(context).size.width*0.6 ),
                    SizedBox(height: 24,),
                    AppText(text: 'No posts available').getText()
                  ],
                ),
              ),
            );
          }else{
            List<PostModel> posts = snapshot.data;
            if(posts.length==0){
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WebsafeSvg.asset('assets/svg/blank_canvas.svg', width:MediaQuery.of(context).size.width*0.6 ),
                      SizedBox(height: 24,),
                      AppText(text: 'No posts available').getText()
                    ],
                  ),
                ),
              );
            }
            return Stack(
              children: [
                GridView.builder(
                  itemCount: posts.length,
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
                              postModelLists: posts,
                              isViewAs: isViewAs,
                              uid: uid,
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
                          child: Image.network(posts[index].imageUrl,fit: BoxFit.cover,
                            loadingBuilder: (context,child,progress){
                              return progress==null?child:Center(
                                child: SizedBox(
                                  width: 56, height: 56,
                                  child: CircularProgressIndicator(
                                    backgroundColor: AppColors().themeBrown,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),),),);},),),
                      ),
                    );},
                ),
                // Align(
                //   alignment: Alignment(0,-1),
                //   child: Container(
                //     width: MediaQuery.of(context).size.width,
                //     height: MediaQuery.of(context).size.height*0.2,
                //     color: Colors.transparent,
                //   ),
                // ),
              ],
            );
          }
        },
      ),
    );
  }
}