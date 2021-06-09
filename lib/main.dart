import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
//flutter build ios

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> imageFile;
  File _image;
  String result = '';
  List<Face> faces;
  var image;
  FaceDetector faceDetector;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    faceDetector = GoogleMlKit.vision.faceDetector(
        FaceDetectorOptions(
            enableClassification: true,
            minFaceSize: 0.1,
            mode: FaceDetectorMode.fast));
  }

  //TODO face detection code
  doFaceDetection() async {
    final inputImage = InputImage.fromFile(_image);
    faces = await faceDetector.processImage(inputImage);
    print(faces.length.toString()+" faces");
    drawRectangleAroundFaces();
    if(faces.length>0){
      if(faces[0].smilingProbability>0.5) {
        result ="Smiling";
      }else{
        result = "Serious";
      }
    }
  }

  drawRectangleAroundFaces() async {
    image = await _image.readAsBytes();
    image = await decodeImageFromList(image);
    setState(() {
      faces;
      result;
    });
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
      if (_image != null) {
        doFaceDetection();
      }
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = image;
      if (_image != null) {
        doFaceDetection();
      }
    });
  }



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    faceDetector.close();

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/wall.jpg'),
                  fit: BoxFit.cover
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 100,
                ),
                Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Stack(children: <Widget>[
                    Center(
                      child: FlatButton(
                        onPressed: _imgFromGallery,
                        onLongPress: _imgFromCamera,
                        child: Container(
                          width: 200,
                          height: 200,
                          margin: EdgeInsets.only(
                            top: 45,
                          ),
                          child: image != null
                              ? Center(
                            child: FittedBox(
                              child: SizedBox(
                                width: image.width.toDouble(),
                                height: image.width.toDouble(),
                                child: CustomPaint(
                                  painter: FacePainter(
                                      rect: faces, imageFile: image
                                  ),
                                ),
                              ),
                            ),
                          )
                              : Container(
                            color: Colors.black,
                            width: 240,
                            height: 250,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    '$result',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'finger_paint', fontSize: 36),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Face> rect;
  var imageFile;
  FacePainter({@required this.rect, @required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 2;

    if (rect != null) {
      for (Face rectangle in rect) {
        canvas.drawRect(rectangle.boundingBox, p);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
