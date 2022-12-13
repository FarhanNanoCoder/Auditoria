import 'package:auditoria/Helping%20Components/AppColors.dart';
import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:auditoria/Helping%20Components/TopAppBar.dart';
import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';

class AboutUs extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors().white,
        body: Column(
          children: [
            TopAppBar(
              leftButtonIcon: Icons.arrow_back_ios_rounded,
              onLeftButtonTap: (){
                Navigator.pop(context);
              },
              pageTitle: 'About us',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 96,),
                    WebsafeSvg.asset('assets/svg/art_museum.svg', width: MediaQuery.of(context).size.width*0.7,),
                    SizedBox(height: 56,),
                    AppText(
                        text: 'Auditoria is a complete online interactive platform for'
                            ' artist to showcase their work, get support and inspiration '
                            'from others. Art enthusiast people can find their need '
                            'and also can hire any artist.',
                        style: 'regular',color: AppColors().themeDarkBlue,size:16 ).getText(),
                    SizedBox(height: 96,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}