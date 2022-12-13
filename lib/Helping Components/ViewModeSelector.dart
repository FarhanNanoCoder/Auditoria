import 'package:flutter/material.dart';

import 'AppColors.dart';
import 'AppText.dart';

class ViewModeSelector extends StatefulWidget{
  final String mode;
  final Function(String value)onChange;


  ViewModeSelector({this.mode, this.onChange});

  @override
  _ViewModeSelectorState createState() => _ViewModeSelectorState();
}

class _ViewModeSelectorState extends State<ViewModeSelector> {
  String mode;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4,),
        Row(
          children: [
            SizedBox(width: 40,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16,),
              width: 144,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors().themeDarkBlue,
                //border: Border.all(width: 1,color: AppColors().grey300),
              ),
              child: Align(
                alignment: Alignment(-1,0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    dropdownColor: AppColors().themeDarkBlue,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,color: AppColors().white,),
                    iconSize: 24,
                    value: mode!=null?mode:widget.mode,
                    onChanged: (value){setState(() {
                      mode = value;
                      widget.onChange(mode);
                    });},
                    items: [
                      DropdownMenuItem(
                        value: 'Public',
                        child: AppText(text: 'Public',size: 12,style: 'regular',color: AppColors().white).getText(),
                      ),
                      DropdownMenuItem(
                        value: 'Private',
                        child: AppText(text: 'Private',size: 12,style: 'regular',color: AppColors().white).getText(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}