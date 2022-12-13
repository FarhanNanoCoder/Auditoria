import 'dart:ui';
import 'package:auditoria/Data%20Models/PostModel.dart';
import 'package:auditoria/Data%20Models/SavedPostModel.dart';
import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppBottomSheetAndDialog.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/Converters.dart';
import 'package:auditoria/Helping%20Components/Toast.dart';
import 'package:auditoria/Pages/ExtensionsOfCreatePostScreen/CreatingPostScreen.dart';
import 'package:auditoria/Pages/ExtensionsOfCreatePostScreen/CreatingPostScreenNew.dart';
import 'package:auditoria/Pages/MainScreens/ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';

class DashboardScreen extends StatefulWidget{
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final commentController = TextEditingController();
  BuildContext mainContext;
  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
  
  showCommentSheet({String pid,String ownerUid}){
    commentController.text='';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.02),
      isScrollControlled: true,
      elevation: 5,
      builder: (context){
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: GestureDetector(
            onTap: (){
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Container(
              height: MediaQuery.of(context).size.height*0.9,
              decoration: BoxDecoration(
                color: AppColors().white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(4),topRight: Radius.circular(4)),
              ),
              child: StreamBuilder(
                stream: DatabaseService().getPostCommentsAsStream(pid),
                builder : (context, commentsQuerySnapshot){
                  if(commentsQuerySnapshot.hasData){
                    QuerySnapshot postQueryComments = commentsQuerySnapshot.data;
                    return Column(
                      children: [
                        SizedBox(height: 4,),
                        Container(
                          height: 4,
                          width: 56,
                          decoration: BoxDecoration(
                            color: AppColors().themeDarkBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(
                          height: 56,
                          child: Center(child: AppText(text: postQueryComments.size==0?'No comments':postQueryComments.size.toString()+' comments',
                              style: 'regular',color: AppColors().themeOffBlue,size: 16).getText()),
                        ),
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width*0.8,
                          decoration: BoxDecoration(
                            color: AppColors().grey100,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        SizedBox(height: 16,),
                        Expanded(
                          child: postQueryComments.size==0?
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(height: 72,),
                                WebsafeSvg.asset('assets/svg/trendy_interface_.svg',//comments_.svg is not working
                                    width: MediaQuery.of(context).size.width*0.5),
                                SizedBox(height: 16,),
                                AppText(text: 'No comments yet',size: 14,
                                    style: 'regular',color: AppColors().themeOffBlue).getText(),
                              ],
                            ),
                          ) :Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: ListView.builder(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              itemCount: postQueryComments.size,
                              itemBuilder: (context,index){
                                DocumentSnapshot doc = postQueryComments.docs[index];
                                CommentsModel commentModel = CommentsModel.fromDocumentSnapshot(doc);
                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        FutureBuilder(
                                          future: DatabaseService().getUserFutureData(commentModel.uid),
                                          builder: (context,userSnapshot){
                                            if(!userSnapshot.hasData ){
                                              return InkWell(
                                                onTap: (){
                                                  Toast(context: context).showTextToast('Unable to find the user');
                                                },
                                                child: Container(
                                                  width: 44, height: 44,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(22),
                                                    color: AppColors().white,
                                                    border: Border.all(width: 1,color: AppColors().grey200),),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(22),
                                                    child: Icon(
                                                      Icons.person_outlined,size: 24, color: AppColors().themeOffBlue,
                                                    ),),
                                                ),
                                              );
                                            }else {
                                              String photoUrl = UserModel.fromDocumentSnapshot(userSnapshot.data).photoUrl;
                                              return InkWell(
                                                onTap: (){
                                                  Navigator.push(context,PageTransition(
                                                      child: ProfileScreen(parentContext:context,isViewAs: true,uid: commentModel.uid,),
                                                      type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                                                },
                                                child: Container(
                                                  width: 44,
                                                  height:44,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(22),
                                                    color: AppColors().white,
                                                    border: Border.all(width: photoUrl==null?1:0,color: AppColors().grey200),),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(22),
                                                    child: photoUrl==null?
                                                    Icon(
                                                      Icons.person_outlined,size: 24, color: AppColors().themeOffBlue,
                                                    ):Image.network(photoUrl,
                                                      loadingBuilder: (context,child,progress){
                                                        return progress==null?child:Center(
                                                          child: SizedBox(
                                                            width: 24, height: 24,
                                                            child: CircularProgressIndicator(
                                                              backgroundColor: AppColors().themeBrown,
                                                              valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),),),);},),),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(width: 16,),
                                        Expanded(
                                          child: InkWell(
                                            onLongPress: (){
                                              if(commentModel.uid == FirebaseAuth.instance.currentUser.uid || ownerUid == FirebaseAuth.instance.currentUser.uid){
                                                AppBottomSheet(
                                                    parentContext: context,
                                                    icons: [Icons.delete_outlined],
                                                    buttonNames: ['Delete comment'],
                                                    onButtonTap: (index){
                                                      if(index==0){
                                                        DatabaseService().deletePostComment(cid: commentModel.cid,pid: pid,totalComments: postQueryComments.size);
                                                      }
                                                    }
                                                ).viewModalBottomSheet();
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(width: 1,color: AppColors().grey100),
                                              ),
                                              child: AppText(
                                                text: commentModel.comment,
                                                style: 'regular',size: 16,color: AppColors().themeDarkBlue,
                                              ).getText(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4,),
                                    Align(
                                      alignment: Alignment(1,1),
                                      child: AppText(
                                        text: getDateTimeFromMilliEpoch(time : commentModel.timestamp),
                                        style: 'regular',size: 10,color: AppColors().grey400,
                                      ).getText(),
                                    ),
                                    SizedBox(height: 16,),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16,),
                          child: Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width-(32+8+44),
                                child: TextFormField(
                                  controller: commentController,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 4,
                                  cursorColor: AppColors().themeBrown,
                                  style: AppText(style: 'regular',size: 16,color: AppColors().themeDarkBlue).getStyle(),
                                  decoration:InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                    hintText: 'Write you comment..',
                                    hintStyle: AppText(style: 'regular', color: AppColors().grey400, size: 16)
                                        .getStyle(),
                                    helperStyle: AppText(
                                        style: 'regular', color: AppColors().grey400, size: 10).getStyle(),
                                    labelStyle: AppText(
                                        style: 'regular', color: AppColors().themeOffBlue, size: 16)
                                        .getStyle(),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide:
                                      BorderSide(color: AppColors().grey300, width: 1),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(color: AppColors().red, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide:
                                      BorderSide(color: AppColors().grey300, width: 1),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8,),
                              SizedBox(
                                height: 44,
                                width: 44,
                                child: Material(
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(22) ),
                                  clipBehavior: Clip.antiAlias,
                                  child: IconButton(
                                    onPressed: ()async{
                                      if(commentController.text.trim().isNotEmpty){
                                        await DatabaseService().addPostComment(
                                          comment: commentController.text.trim(),
                                          pid: pid,
                                          totalComments: postQueryComments.size,
                                        );
                                        commentController.text='';
                                      }
                                    },
                                    icon: Icon(
                                      Icons.send_outlined,
                                      size: 24,
                                      color: AppColors().themeBrown,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),),
                      ],
                    );
                  }else{
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: AppColors().themeBrown,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                      ),
                    );
                  }
                }
              ),
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    mainContext = context;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: AppColors().white,
        body: StreamBuilder(
          stream: DatabaseService().getAllPostsAsStream(),
          builder: (context,snapshot){
            if(!snapshot.hasData || snapshot.connectionState ==ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: AppColors().themeBrown,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                ),
              );
            }else{
              QuerySnapshot querySnapshot = snapshot.data;
              if(querySnapshot.docs.length==0){
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24,vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WebsafeSvg.asset('assets/svg/artist_post_.svg',width: MediaQuery.of(context).size.width*0.6),
                        SizedBox(height: 16,),
                        AppText(text: 'It seems that there are not any posts '
                            'available right now. What\'s about you post something first?',
                            size: 14,style: 'regular',color: AppColors().themeDarkBlue).getText(),
                        SizedBox(height: 56,),
                        TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
                              backgroundColor: AppColors().themeDarkBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28),)),
                          onPressed: (){
                            Navigator.push(context,PageTransition(
                                child: CreatingPostScreenNew(),
                                type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));},
                          child: AppText(text: 'Let\'s post something',size: 16,
                              style: 'medium', color: AppColors().white).getText(),
                        ),
                      ],),),);
              }
              return ListView.builder(
                itemCount: querySnapshot.size,
                itemBuilder: (context,index){
                  PostModel post = PostModel.fromDocumentSnapshot(querySnapshot.docs[index]);
                  String postTime = getDateTimeFromMilliEpoch(time: post.timestamp);
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    color: AppColors().white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:  EdgeInsets.fromLTRB(24,16,16,16),
                          child: FutureBuilder(
                              future: DatabaseService().getUserFutureData(post.uid),
                              builder:(context,userSnapshot){
                                if(!userSnapshot.hasData){
                                  return Row(
                                    children: [
                                      Container(
                                        width: 56, height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(28),
                                          color: AppColors().white,
                                          border: Border.all(width: 1,color: AppColors().grey200),),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(28),
                                          child: Icon(
                                            Icons.person_outlined,size: 24, color: AppColors().themeOffBlue,
                                          ),),
                                      ),
                                      SizedBox(width: 16,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText(text: 'User name',size: 16,style: 'medium',color: AppColors().themeDarkBlue).getText(),
                                          AppText(text: '26 July, 2020',size: 10,style: 'regular',color: AppColors().themeOffBlue).getText(),
                                        ],
                                      ),
                                      Spacer(),
                                      (post.uid == FirebaseAuth.instance.currentUser.uid)?
                                      SizedBox(width: 0,height: 0,): Container(
                                        height: 56,
                                        width: 56,
                                        child: Material(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(28) ),
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            onTap: (){},
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.person_add_alt,size: 24,color: AppColors().themeDarkBlue,),
                                                AppText(text: 'Follow',size: 10,style: 'regular',color: AppColors().themeOffBlue).getText(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }else{
                                  UserModel user = UserModel.fromDocumentSnapshot(userSnapshot.data);

                                  return Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(28),
                                          color: AppColors().white,
                                          border: Border.all(width: user.photoUrl==null?1:0,color: AppColors().grey200),),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(28),
                                          child: user.photoUrl==null?
                                          Icon(
                                            Icons.person_outlined,size: 24, color: AppColors().themeOffBlue,
                                          ):Image.network(user.photoUrl,
                                            loadingBuilder: (context,child,progress){
                                              return progress==null?child:Center(
                                                child: SizedBox(
                                                  width: 24, height: 24,
                                                  child: CircularProgressIndicator(
                                                    backgroundColor: AppColors().themeBrown,
                                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),),),);},),),
                                      ),
                                      SizedBox(width: 16,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Material(
                                              color: Colors.transparent,
                                              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(0) ),
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                onTap:(){
                                                  Navigator.push(context,PageTransition(
                                                      child: ProfileScreen(parentContext:context,isViewAs: true,uid: post.uid,),
                                                      type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                                                },
                                                child: AppText(text: user.username,size: 16,style: 'medium',color: AppColors().themeDarkBlue).getText(),
                                              ),
                                            ),
                                          ),
                                          AppText(text: postTime.toString(),size: 10,style: 'regular',color: AppColors().themeOffBlue).getText(),
                                        ],
                                      ),
                                      Spacer(),
                                      (post.uid == FirebaseAuth.instance.currentUser.uid)?
                                      Container(
                                        height: 24,
                                        width: 24,
                                        child: Material(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(12) ),
                                          clipBehavior: Clip.antiAlias,
                                          child: InkWell(
                                            onTap: (){
                                              AppBottomSheet(
                                                  parentContext: context,
                                                  icons: [Icons.edit_outlined,Icons.delete_outlined],
                                                  buttonNames: ['Edit post','Delete post'],
                                                  onButtonTap: (index){
                                                    if(index==0){
                                                      Navigator.push(context,PageTransition(
                                                          child: CreatingPostScreenNew(
                                                            pid: post.pid,
                                                            description: post.description,
                                                            tags: post.tags,
                                                            existingWorkUrl: post.imageUrl,
                                                          ),
                                                          type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                                                    }else if(index == 1){
                                                      DatabaseService().deletePost(context: mainContext,pid:post.pid,totalLikes: post.totalLikes);
                                                    }
                                                  }
                                              ).viewModalBottomSheet();
                                            },
                                            child: Center(child: Icon(Icons.more_vert,size: 24,color: AppColors().themeDarkBlue,)),
                                          ),
                                        ),
                                      ) :
                                      Container(
                                        height: 56,
                                        width: 56,
                                        child: Material(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(28) ),
                                          clipBehavior: Clip.antiAlias,
                                          child: StreamBuilder(
                                              stream: DatabaseService().allFollowingsCollection
                                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                                  .collection('userFollowings').doc(post.uid).snapshots(),

                                              builder: (context, followingsSnapshot) {
                                                if(!followingsSnapshot.hasData){
                                                  return InkWell(
                                                    onTap: (){
                                                      DatabaseService().updateFollowingsAndFollowers(
                                                          uid: post.uid);
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.person_add_alt,size: 24,color: AppColors().themeOffBlue,),
                                                        AppText(text: 'Follow',size: 10,style: 'regular',color: AppColors().themeOffBlue).getText(),
                                                      ],
                                                    ),
                                                  );
                                                }else{
                                                  DocumentSnapshot doc = followingsSnapshot.data;
                                                  return InkWell(
                                                    onTap: (){
                                                      DatabaseService().updateFollowingsAndFollowers(
                                                          uid: post.uid);
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(doc.exists?Icons.how_to_reg_outlined:
                                                        Icons.person_add_alt,size: 24,color:
                                                        doc.exists?AppColors().themeBrown:AppColors().themeOffBlue,),
                                                        AppText(text: doc.exists?'Following':
                                                        'Follow',size: 10,style: 'regular',color:
                                                        doc.exists?AppColors().themeBrown:AppColors().themeOffBlue).getText(),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              }
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                          ),
                        ),
                        (post.description!=null && post.description.length!=0)?Padding(
                          padding: EdgeInsets.fromLTRB(24,0,24,16),
                          child: AppText(text: post.description,size: 16,style: 'regular',color: AppColors().themeOffBlue).getText(),
                        ): SizedBox(height: 0,),
                        (post.tags!=null && post.tags.length!=0)?Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(24,0,24,16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: post.tags.map((e){
                                return Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors().themeBrown,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: AppText(text: e,size: 14,
                                            style: 'regular', color: AppColors().white).getText(),
                                      ),
                                    ),
                                    SizedBox(width: 16,),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ):SizedBox(height: 0,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors().white,
                            border: Border.all(width: post.imageUrl==null?1:0,color: AppColors().grey200),),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: post.imageUrl==null?
                            Icon(
                              Icons.image_outlined,size: 56, color: AppColors().grey300,
                            ):Image.network(post.imageUrl,fit: BoxFit.cover,
                              loadingBuilder: (context,child,progress){
                                return progress==null?child:Center(
                                  child: SizedBox(
                                    width: 56, height: 56,
                                    child: CircularProgressIndicator(
                                      backgroundColor: AppColors().themeBrown,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),),),);},),),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  StreamBuilder(
                                    stream: DatabaseService().getPostLikesAsStream(post.pid),
                                    builder: (context,postLikesSnapshot){
                                      if(postLikesSnapshot.hasData){
                                        PostLikes postLikes = PostLikes.fromDocumentSnapshot(postLikesSnapshot.data);
                                        return Material(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(24) ),
                                          clipBehavior: Clip.antiAlias,
                                          child: IconButton(
                                            onPressed: (){
                                              DatabaseService().updatePostLikes(ownerUid: post.uid,pid: post.pid,postLikes: postLikes);
                                            },
                                            icon: Icon(
                                              postLikes.likes[FirebaseAuth.instance.currentUser.uid]==null?Icons.favorite_border:Icons.favorite,
                                              size: 24,
                                              color: AppColors().themeBrown,
                                            ),
                                          ),
                                        );
                                      }else{
                                        return SizedBox(
                                          height: 24,width: 24,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor: AppColors().themeBrown,
                                              valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                                            ),),
                                        );
                                      }
                                    },
                                  ),
                                  AppText(text: post.totalLikes.toString()+'  reacts',size: 10,
                                      style: 'regular', color: AppColors().themeOffBlue).getText(),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(24) ),
                                    clipBehavior: Clip.antiAlias,
                                    child: IconButton(
                                      onPressed: (){
                                        showCommentSheet(pid: post.pid,ownerUid: post.uid);
                                      },
                                      icon: Icon(Icons.chat_bubble_outline_rounded,size: 24,color: AppColors().themeBrown,),
                                    ),
                                  ),
                                  AppText(text: post.totalComments.toString()+'  comments',size: 10,
                                      style: 'regular', color: AppColors().themeOffBlue).getText(),
                                ],
                              ),
                              StreamBuilder(
                                stream: DatabaseService().savedPostsCollection
                                    .doc(FirebaseAuth.instance.currentUser.uid)
                                    .collection('userSavedPosts').doc(post.pid).snapshots(),
                                builder: (context, snapshot) {
                                  if(snapshot.hasData ){
                                    DocumentSnapshot doc = snapshot.data;
                                    return Column(
                                      children: [
                                        Material(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(24) ),
                                          clipBehavior: Clip.antiAlias,
                                          child: IconButton(
                                            onPressed: (){
                                              if(post.uid==FirebaseAuth.instance.currentUser.uid){
                                                Toast(context: context).showTextToast('Can\'t save.That post belongs to you');
                                              }else{
                                                DatabaseService().updateSavedPosts(pid: post.pid,context: context);
                                              }
                                            },
                                            icon: Icon(doc.exists?Icons.bookmark_rounded:Icons.bookmark_border_rounded,size: 24,color: AppColors().themeBrown,),
                                          ),
                                        ),
                                        AppText(text: 'Saved',size: 10,
                                            style: 'regular', color: AppColors().themeOffBlue).getText(),
                                      ],
                                    );
                                  }else{
                                    return Column(
                                      children: [
                                        Material(
                                          color: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(24) ),
                                          clipBehavior: Clip.antiAlias,
                                          child: IconButton(
                                            onPressed: (){
                                              if(post.uid==FirebaseAuth.instance.currentUser.uid){
                                                Toast(context: context).showTextToast('Can\'t save.That post belongs to you');
                                              }else{
                                                DatabaseService().updateSavedPosts(pid: post.pid,context: context);
                                              }
                                            },
                                            icon: Icon(Icons.bookmark_border_rounded,size: 24,color: AppColors().themeBrown,),
                                          ),
                                        ),
                                        AppText(text: 'Save',size: 10,
                                            style: 'regular', color: AppColors().themeOffBlue).getText(),
                                      ],
                                    );
                                  }
                                }
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 6, color: AppColors().grey200,),
                      ],),);
                },);
            }
          },
        ),
      ),
    );
  }
}

///conclusion
// Center(
// child: Padding(
// padding: EdgeInsets.symmetric(horizontal: 24,vertical: 24),
// child: Column(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// WebsafeSvg.asset('assets/svg/artist_post_.svg',width: MediaQuery.of(context).size.width*0.4),
// SizedBox(height: 16,),
// AppText(text: 'It seems that there are not any posts '
// 'available right now. What\'s about you post something?',
// size: 14,style: 'regular',color: AppColors().themeDarkBlue).getText(),
// SizedBox(height: 56,),
// TextButton(
// style: TextButton.styleFrom(
// padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
// backgroundColor: AppColors().themeDarkBlue,
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(28),
// )
// ),
// onPressed: (){
// Navigator.push(context,PageTransition(
// child: CreatingPostScreen(),
// type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
// },
// child: AppText(text: 'Let\'s post something',size: 16,
// style: 'medium', color: AppColors().white).getText(),
// ),
// ],
// ),
// ),
// ),