import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/FlowNavigationBar.dart';
import 'package:auditoria/Pages/MainScreens/CreatePostScreen.dart';
import 'package:auditoria/Pages/MainScreens/DashboardScreen.dart';
import 'package:auditoria/Pages/MainScreens/SearchScreen.dart';
import 'package:auditoria/Pages/MainScreens/SettingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'MainScreens/ProfileScreen.dart';



class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController _controller = PageController(initialPage: 0);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //LiquidController _liquidController = LiquidController();
  int currentIndex=0;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white,
      body:
      /*LiquidSwipe(
        liquidController: _liquidController,
        enableLoop: false,
        enableSideReveal: true,
        waveType: WaveType.liquidReveal,
        onPageChangeCallback: (position){
          setState(() {
            currentIndex = position;
          });
        },
        pages: [
          DashboardScreen(),
          SearchScreen(),
          CreatePostScreen(),
          ProfileScreen(isViewAs: false,uid: _auth.currentUser.uid,),
          SettingsScreen(),
        ],

      ),*/
      PageView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        onPageChanged: (position){
          setState(() {
            currentIndex = position;
            //print(currentIndex);
          });
        },
        children: [
          DashboardScreen(),
          SearchScreen(),
          CreatePostScreen(),
          ProfileScreen(isViewAs: false,uid: _auth.currentUser.uid,parentContext: context,),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: FlowNavigationBar(
        initialIndex: currentIndex,
        height: 56,
        circleColor: AppColors().themeDarkBlue,
        backgroundColor: AppColors().white,
        iconSize: 24,
        iconColor: AppColors().themeDarkBlue,
        activeIconColor: AppColors().white,
        onIndexChangedListener: (index){
          setState(() {
            currentIndex = index;
            /*_liquidController.animateToPage(page: currentIndex,
              dur6ation: 200,
            );*/
            _controller.animateToPage(currentIndex,
                duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
            //print(currentIndex);
          });
        },
        icons: [
          Icons.dashboard_outlined,
          Icons.person_search_outlined,
          Icons.add_a_photo_outlined,
          Icons.person_outline_rounded,
          Icons.settings_outlined,
        ],
      ),
    );
  }
}