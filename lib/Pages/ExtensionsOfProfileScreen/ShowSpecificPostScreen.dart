import 'dart:ui';

import 'package:auditoria/Data%20Models/PostModel.dart';
import 'package:auditoria/Data%20Models/UserModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppBottomSheetAndDialog.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/Converters.dart';
import 'package:auditoria/Helping%20Components/Toast.dart';
import 'package:auditoria/Pages/ExtensionsOfCreatePostScreen/CreatingPostScreenNew.dart';
import 'package:auditoria/Pages/MainScreens/ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';

class ShowSpecificPostScreen extends StatefulWidget{
   int startingIndex;
   String uid;
   List<PostModel> postModelLists;
   bool isViewAs;
   ShowSpecificPostScreen({this.startingIndex, this.uid, this.postModelLists, this.isViewAs});

  @override
  _ShowSpecificPostScreenState createState() => _ShowSpecificPostScreenState();
}

class _ShowSpecificPostScreenState extends State<ShowSpecificPostScreen> {
  PageController _controller;
  int currentIndex=-1;
  bool initialized = false;
  final commentController = TextEditingController();

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
    if(!initialized){
      currentIndex = widget.startingIndex;
      _controller = PageController(initialPage: currentIndex);
      initialized = true;
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSwitcher(
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                duration: Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey<String>(widget.postModelLists[currentIndex].pid),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.postModelLists[currentIndex].imageUrl),
                      fit: BoxFit.cover,
                    ),),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8,sigmaY: 8),
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  width: MediaQuery.of(context).size.width,
                  height: 56,
                  color: Colors.black.withOpacity(0.1),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment(-1,0),
                        child: Material(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(24) ),
                          clipBehavior: Clip.antiAlias,
                          child: IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back_ios_outlined),
                            iconSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: AppText(text: 'Posts',size: 16,style: 'regular',
                            color: Colors.white).getText(),
                      ),
                      !widget.isViewAs?Align(
                        alignment: Alignment(1,0),
                        child: Material(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(24) ),
                          clipBehavior: Clip.antiAlias,
                          child: IconButton(
                            onPressed: (){
                              AppBottomSheet(
                                  parentContext: context,
                                  icons: [Icons.edit_outlined,Icons.delete_outlined],
                                  buttonNames: ['Edit post','Delete post'],
                                  onButtonTap: (index){
                                    if(index==0){
                                      Navigator.push(context,PageTransition(
                                          child: CreatingPostScreenNew(
                                            parentContext: context,
                                            pid: widget.postModelLists[currentIndex].pid,
                                            description: widget.postModelLists[currentIndex].description,
                                            tags: widget.postModelLists[currentIndex].tags,
                                            existingWorkUrl: widget.postModelLists[currentIndex].imageUrl,
                                          ),
                                          type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                                    }else if(index == 1){
                                      DatabaseService()
                                          .deletePost(
                                          context: context,
                                          pid:widget.postModelLists[currentIndex].pid,
                                          totalLikes: widget.postModelLists[currentIndex].totalLikes);
                                    }
                                  }
                              ).viewModalBottomSheet();
                            },
                            icon: Icon(Icons.notes_rounded),
                            iconSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ):Align(
                        alignment: Alignment(1,0),
                        child: Container(
                          height: 56, width: 56,
                          color: Colors.transparent,
                          child: StreamBuilder(
                              stream: DatabaseService().savedPostsCollection
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .collection('userSavedPosts').doc(widget.postModelLists[currentIndex].pid).snapshots(),
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
                                            if(widget.postModelLists[currentIndex].uid==FirebaseAuth.instance.currentUser.uid){
                                              Toast(context: context).showTextToast('Can\'t save.That post belongs to you');
                                            }else{
                                              DatabaseService().updateSavedPosts(pid: widget.postModelLists[currentIndex].pid,context: context);
                                            }
                                          },
                                          icon: Icon(doc.exists?Icons.bookmark_rounded:Icons.bookmark_border_rounded,size: 24,color: AppColors().themeBrown,),
                                        ),
                                      ),
                                    ],
                                  );
                                }else{
                                  return Container(
                                    child:
                                      Material(
                                        color: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(24) ),
                                        clipBehavior: Clip.antiAlias,
                                        child: IconButton(
                                          onPressed: (){
                                            if(widget.postModelLists[currentIndex].uid==FirebaseAuth.instance.currentUser.uid){
                                              Toast(context: context).showTextToast('Can\'t save.That post belongs to you');
                                            }else{
                                              DatabaseService().updateSavedPosts(pid: widget.postModelLists[currentIndex].pid,context: context);
                                            }
                                          },
                                          icon: Icon(Icons.bookmark_border_rounded,size: 24,color: AppColors().themeBrown,),
                                        ),
                                      ),
                                  );
                                }
                              }
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 64,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height-96,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: widget.postModelLists.length,
                    onPageChanged: (index){setState(() {currentIndex = index;});},
                    itemBuilder: (context,index){
                      return Padding(
                        padding: EdgeInsets.fromLTRB(24,0,24,56),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16,),
                            Align(
                              alignment: Alignment(1,0),
                              child: AppText(
                                text: getDateTimeFromMilliEpoch(time : widget.postModelLists[index].timestamp),
                                style: 'regular',size: 12,color: Colors.white,
                              ).getText(),
                            ),
                            SizedBox(height: 8,),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width-48,
                                    height: MediaQuery.of(context).size.width-48,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                          image: NetworkImage(widget.postModelLists[index].imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [BoxShadow(
                                            color: Colors.black.withOpacity(1),
                                            spreadRadius: 5,
                                            blurRadius: 10,
                                            offset: Offset(0,5)
                                        ),]
                                    ),
                                  ),
                                ),
                                FirebaseAuth.instance.currentUser.uid!=widget.postModelLists[currentIndex].uid?
                                Positioned(
                                  left: 16,
                                  top: 16,
                                  child: InkWell(
                                    onTap:(){
                                      Navigator.push(context,PageTransition(
                                          child: ProfileScreen(parentContext:context,isViewAs: true,uid: widget.postModelLists[currentIndex].uid,),
                                          type: PageTransitionType.bottomToTop,duration: Duration(milliseconds: 300)));
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        color: AppColors().themeDarkBlue,
                                        border: Border.all(width: 1,color: AppColors().themeBrown),),
                                      child: FutureBuilder(
                                          future: DatabaseService().getUserFutureData(widget.postModelLists[currentIndex].uid),
                                          builder: (context,userSnapshot){
                                            if(userSnapshot.hasData){
                                              UserModel user = UserModel.fromDocumentSnapshot(userSnapshot.data);
                                              return ClipRRect(
                                                borderRadius: BorderRadius.circular(22),
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
                                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),),),);},),);
                                            }else{
                                              return Icon(
                                                Icons.person_outlined,size: 24, color: AppColors().themeOffBlue,
                                              );
                                            }
                                          }
                                      ),
                                    ),
                                  ),
                                ):SizedBox(width: 0,height: 0,),
                                Positioned(
                                  bottom: 16,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width-48,
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(horizontal: 16,),
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: widget.postModelLists[index].tags.map((e){
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
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24,),
                            Expanded(
                              child: SingleChildScrollView(
                                child: AppText(
                                  text: widget.postModelLists[index].description,
                                  style: 'regular',size: 16,color: Colors.white,
                                ).getText(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left : 24,
                bottom: 4,
                child: StreamBuilder(
                  stream: DatabaseService().getPostLikesAsStream(widget.postModelLists[currentIndex].pid),
                  builder: (context,snapshot){
                    if(!snapshot.hasData){
                      return SizedBox(
                        height: 24,width: 24,
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: AppColors().themeBrown,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                          ),),
                      );
                    }else{
                      PostLikes postLikes = PostLikes.fromDocumentSnapshot(snapshot.data);
                      return Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(24) ),
                            clipBehavior: Clip.antiAlias,
                            child: IconButton(
                              onPressed: (){
                                DatabaseService()
                                    .updatePostLikes(ownerUid: widget.postModelLists[currentIndex].uid,
                                    pid: widget.postModelLists[currentIndex].pid,postLikes: postLikes);
                              },
                              icon: Icon(
                                postLikes.likes[FirebaseAuth.instance.currentUser.uid]==null?Icons.favorite_border:Icons.favorite,
                                size: 24,
                                color: AppColors().themeBrown,
                              ),
                            ),
                          ),
                          AppText(
                            text: postLikes.likes.length.toString(),
                            style: 'regular',size: 14,color: Colors.white,
                          ).getText(),
                        ],
                      );
                    }
                  },
                ),
              ),
              Positioned(
                right : 24,
                bottom: 4,
                child: StreamBuilder(
                  stream: DatabaseService().getSpecificPostAsStream(widget.postModelLists[currentIndex].pid),
                  builder: (context,snapshot){
                    if(!snapshot.hasData){
                      return SizedBox(
                        height: 24,width: 24,
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: AppColors().themeBrown,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                          ),),
                      );
                    }else{
                      PostModel _postModel = PostModel.fromDocumentSnapshot(snapshot.data);
                      return Row(
                        children: [
                          AppText(
                            text: _postModel.totalComments.toString(),
                            style: 'regular',size: 14,color: Colors.white,
                          ).getText(),
                          Material(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(24) ),
                            clipBehavior: Clip.antiAlias,
                            child: IconButton(
                              onPressed: (){
                                 showCommentSheet(pid: widget.postModelLists[currentIndex].pid,
                                     ownerUid: widget.postModelLists[currentIndex].uid);
                              },
                              icon: Icon(Icons.chat_bubble_outline_rounded,size: 24,color: AppColors().themeBrown,),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                child: Container(
                  height: 28,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: AppText(
                      text: (currentIndex+1).toString()+'/'+widget.postModelLists.length.toString(),
                      style: 'regular',size: 12,color: Colors.white,
                    ).getText(),
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