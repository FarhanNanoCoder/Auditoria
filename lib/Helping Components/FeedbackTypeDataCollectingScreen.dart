import 'package:auditoria/Helping%20Components/AppText.dart';
import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'AppColors.dart';

// ignore: must_be_immutable
class FeedBackTypeDataCollectingScreen extends StatelessWidget{
  String svgPath,title,hint,buttonText,extraText;
  @required
  final Function (String feedBack) onSubmit;
  final _feedBackTextController = TextEditingController();
  FeedBackTypeDataCollectingScreen({this.svgPath, this.title, this.hint,
      this.buttonText, this.extraText, this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24,vertical: 24),
      width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      child: Column(
        children: [
          svgPath!=null?WebsafeSvg.asset(svgPath,width: MediaQuery.of(context).size.width*.6):SizedBox(height: 4,),
          SizedBox(height: 48,),
          Align(
            alignment: Alignment(-1,0),
            child: AppText(text: title,style: 'regular',size: 16,color: AppColors().themeDarkBlue).getText(),
          ),
          SizedBox(height: 16,),
          Container(
            height: MediaQuery.of(context).size.height*.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors().grey300,width: 1),
            ),
            child: TextFormField(
              controller: _feedBackTextController,
              autofocus: false,
              cursorColor: AppColors().themeBrown,
              style: AppText(style: 'regular',color: AppColors().themeDarkBlue,size: 16).getStyle(),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppText(style: 'regular',color: AppColors().grey800,size: 16).getStyle(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),),
            ),
          ),
          SizedBox(height: 24,),
          TextButton(
            onPressed: (){
              onSubmit(_feedBackTextController.text.trim());
            },
            style: TextButton.styleFrom(
                minimumSize:Size(MediaQuery.of(context).size.width,56),
                padding: EdgeInsets.all(0),
                backgroundColor: AppColors().themeDarkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                )
            ),
            child: AppText(text: buttonText,style: 'medium',color: AppColors().white,size: 16).getText(),
          ),
          SizedBox(height: 24,),
          extraText!=null?Align(
            alignment: Alignment(-1,0),
            child: AppText(text: extraText,style: 'regular',color: AppColors().themeOffBlue,size: 14).getText(),)
              :SizedBox(height: 4,),
        ],
      ),
    );
  }

}