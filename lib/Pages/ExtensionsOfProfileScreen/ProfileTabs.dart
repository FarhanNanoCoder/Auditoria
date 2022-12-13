import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/ProfileTabFollowers.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/ProfileTabFollowings.dart';
import 'package:auditoria/Pages/ExtensionsOfProfileScreen/ProfileTabPosts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileTabs extends StatefulWidget{
  String uid;
  bool isViewAs;
  ProfileTabs({this.uid,this.isViewAs});

  @override
  _ProfileTabsState createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> {
  List<IconData> icons = [
    Icons.wysiwyg,
    Icons.person_add_outlined,
    Icons.how_to_reg_outlined,
  ];
  int currentPosition =0;
  Widget currentTab(){
    if(currentPosition==0){
      return ProfileTabPosts(uid: widget.uid,isViewAs: widget.isViewAs,);
    }else if(currentPosition == 1){
      return ProfileTabFollowers(uid: widget.uid,isViewAs: widget.isViewAs,);
    }
    return ProfileTabFollowings(uid: widget.uid,isViewAs: widget.isViewAs,);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 22),
          width: MediaQuery.of(context).size.width,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.transparent,
            border: Border.all(width: 0,color: AppColors().grey200),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment((currentPosition-1)*1.0,1),
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Container(
                  width: (MediaQuery.of(context).size.width-48)*(1/3),
                  height: 2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: AppColors().themeDarkBlue,
                  ),
                ),
              ),
              Row(
                children: icons.map((e) => SizedBox(
                  height: 56,
                  width: (MediaQuery.of(context).size.width-48)*(1/3),
                  child: IconButton(
                    onPressed: (){
                      setState(() {
                        currentPosition = icons.indexOf(e);
                      });
                    },
                    icon: Icon(e),
                    iconSize: 24,
                    color: AppColors().themeDarkBlue,
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: 16,),
        Expanded(child: currentTab()),
      ],
    );
  }
}