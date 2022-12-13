import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'AppColors.dart';


// ignore: must_be_immutable
class EditImageViewer extends StatefulWidget{
  final String photoUrl;
  final Widget onNull;
  String tootltip;
  final Function(File imageFile) onImageChange;
  final double height,width;

  EditImageViewer({this.tootltip,this.photoUrl, this.onImageChange, this.height, this.width,this.onNull});

  @override
  _EditImageViewerState createState() => _EditImageViewerState();
}

class _EditImageViewerState extends State<EditImageViewer> {
File currentlySelectedImage;

  Widget getImage(String photoUrl){
    if(photoUrl!=null && currentlySelectedImage==null){
      return Image.network(
          photoUrl,width: widget.width,height: widget.height,
          fit: BoxFit.cover,
          loadingBuilder: (context,child,progress){
            return progress==null?child:Center(
              child: SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  backgroundColor: AppColors().themeBrown,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors().themeDarkBlue),
                ),
              ),);}
      );
    }
    return Image.file(currentlySelectedImage, width: widget.width, height: widget.height,);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.transparent,
            border: Border.all(width: 1,color: AppColors().grey200),
          ),
          child: Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: (widget.photoUrl==null && currentlySelectedImage ==null)?
                widget.onNull:getImage(widget.photoUrl)
            ),
          ),),
        Positioned(
          bottom: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0) ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: AppColors().white.withOpacity(0.6),
              ),
              child: IconButton(
                splashColor: AppColors().themeDarkBlue,
                onPressed: (){
                  PickImage(
                      onImageSelect: (image){
                        setState(() {
                          currentlySelectedImage = image;
                          widget.onImageChange(currentlySelectedImage);
                        });
                      }
                  ).chooseFile();
                },
                icon: Icon(Icons.edit_outlined),
                iconSize: 24,
                color: AppColors().themeDarkBlue,
                tooltip: widget.tootltip,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PickImage {
  final Function(File image) onImageSelect;
  PickImage({this.onImageSelect});

  Future chooseFile()async{
    PickedFile pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      print(pickedFile.path);
      File croppedImage = await ImageCropper.
      cropImage(sourcePath: pickedFile.path,aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        compressQuality: 80,
        maxWidth: 1000,
        maxHeight: 1000,
        androidUiSettings: AndroidUiSettings(
          activeControlsWidgetColor: AppColors().themeBrown,
          backgroundColor: AppColors().themeDarkBlue,
        ),
      );

      if(croppedImage!=null){
        onImageSelect(croppedImage);
      }
    }else{
      print('No file picked');
    }
  }

}