import 'package:auditoria/Data%20Models/NotificationsModel.dart';
import 'package:auditoria/Data%20Models/PostModel.dart';
import 'package:auditoria/Database/DatbaseService.dart';
import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/Converters.dart';
import 'package:auditoria/Helping%20Components/TopAppBar.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/ShowSpecificPostScreen.dart';
import 'package:auditoria/Pages/MainScreens/ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:page_transition/page_transition.dart';
import 'package:websafe_svg/websafe_svg.dart';

class NotificationScreen extends StatelessWidget {
  int recentNotifications =0;

  NotificationScreen({this.recentNotifications});

  showPost({BuildContext context, String pid,String eventType}) async {
    bool isViewAs = true;
    if(eventType=='like'){isViewAs=false;}
    PostModel postModel = PostModel.fromDocumentSnapshot(
        await DatabaseService().getSpecificPostAsFuture(pid));
    Navigator.push(context, PageTransition(
            child: ShowSpecificPostScreen(isViewAs: isViewAs,
              postModelLists: [postModel,], startingIndex: 0, uid: postModel.uid,),
            type: PageTransitionType.bottomToTop, duration: Duration(milliseconds: 300)));
  }

  resetRecentNotifications() async {
    await DatabaseService()
        .userLiveData
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({'recentNotifications': 0});
  }

  @override
  Widget build(BuildContext context) {
    resetRecentNotifications();
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: Column(
          children: [
            TopAppBar(
              leftButtonIcon: Icons.arrow_back_ios_rounded,
              onLeftButtonTap: () {
                Navigator.pop(context);
              },
              pageTitle: 'Notifications',
            ),
            Expanded(
              child: FutureBuilder(
                future: DatabaseService().getUserNotificationsAsFuture(
                    FirebaseAuth.instance.currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    QuerySnapshot querySnapshot = snapshot.data;
                    // print(querySnapshot.size);
                    if (querySnapshot.size == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 196,),
                          WebsafeSvg.asset('assets/svg/notification_.svg', width: MediaQuery.of(context).size.width * 0.5),
                          SizedBox(height: 44,),
                          AppText(text: 'No notifications yet', style: 'regular', size: 14, color: AppColors().themeDarkBlue).getText(),
                        ],
                      );
                    }
                    return ListView.builder(
                      itemCount: querySnapshot.size,
                      itemBuilder: (context, index) {
                        bool highlight = false;
                        String message;
                        var notificationModel;
                        if (querySnapshot.docs[index].data()['eventType'] == 'like') {
                          notificationModel = LikeNotificationModel.fromDocumentSnapshot(querySnapshot.docs[index]);
                          message = ' has liked your post';
                        } else if (querySnapshot.docs[index].data()['eventType'] == 'follow') {
                          notificationModel = FollowNotificationModel.fromDocumentSnapshot(querySnapshot.docs[index]);
                          message = ' has started following you';
                        }else if(querySnapshot.docs[index].data()['eventType'] == 'followersPost'){
                          notificationModel = FollowersPostNotificationModel.fromDocumentSnapshot(querySnapshot.docs[index]);
                          message=' posted something. Check it out!';
                        }
                        if(recentNotifications>0){
                          highlight=true;
                          recentNotifications--;
                        }
                        return Dismissible(
                          onDismissed: (direction) async {
                            querySnapshot.docs.removeAt(index);
                            DatabaseService()
                                .notificationsCollection
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .collection('userNotifications')
                                .doc(querySnapshot.docs[index].data()['did'])
                                .delete();
                          },
                          background: Container(
                            color: AppColors().themeOffBlue,
                            child: Icon(
                              Icons.delete_outlined,
                              size: 24,
                              color: AppColors().white,
                            ),
                          ),
                          key: ValueKey(index.toString()),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 72,
                                color: highlight?AppColors().grey200:AppColors().white, //notificationModel.isSeen?AppColors().white:AppColors().grey200,
                                child: Material(
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0)),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () {
                                      if (notificationModel.eventType == 'follow') {
                                        Navigator.push(context,
                                            PageTransition(
                                                child: ProfileScreen(isViewAs: true, uid: notificationModel.uid, parentContext: context,),
                                                type: PageTransitionType.bottomToTop, duration: Duration(milliseconds: 300)));
                                      } else if (notificationModel.eventType == 'like' || notificationModel.eventType == 'followersPost') {
                                        showPost(context: context, pid: notificationModel.pid,eventType: notificationModel.eventType);
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.symmetric(horizontal: 24),
                                      height: 72,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(22),
                                              color: AppColors().white,
                                              border: Border.all(width: 1, color: AppColors().grey200),),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(22),
                                              child:
                                                  notificationModel.imageUrl == null
                                                      ? Icon(Icons.image_outlined, size: 24,
                                                          color: AppColors().themeOffBlue,)
                                                      : Image.network(
                                                          notificationModel.imageUrl,
                                                          loadingBuilder: (context, child, progress) {
                                                            return progress == null ? child : Center(
                                                              child: SizedBox(width: 36, height: 36,
                                                                      child: CircularProgressIndicator(
                                                                        backgroundColor: AppColors().themeBrown,
                                                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),),),);
                                                          },
                                                          errorBuilder:
                                                              (context, object, stack) {
                                                            return Icon(
                                                              Icons.person_outline,
                                                              size: 24, color: AppColors().themeOffBlue,
                                                            );
                                                          },
                                                        ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text: notificationModel.username +' ',
                                                      style: AppText(style: 'medium', size: 14, color: AppColors().themeDarkBlue).getStyle(),
                                                      children: [
                                                        TextSpan(
                                                          text: message,
                                                          style: AppText(style: 'regular',
                                                                  size: 14, color: AppColors().themeDarkBlue).getStyle(),
                                                        ),
                                                      ]),
                                                ),
                                                // AppText(text: notificationModel.getMessage(),
                                                //     style: 'regular', size: 16,color: AppColors().themeDarkBlue).getText(),
                                                AppText(text: getDateTimeFromMilliEpoch(
                                                            time: notificationModel.timestamp),
                                                        style: 'regular',
                                                        size: 10,
                                                        color: AppColors().themeDarkBlue).getText(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 1,
                                color: AppColors().grey200,
                              )
                            ],
                          ),
                        );
                      },
                    );
                    return null;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: AppColors().themeBrown,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors().themeDarkBlue),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
