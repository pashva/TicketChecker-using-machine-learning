import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:ml_firebase/image%20label.dart';
import 'package:http/http.dart' as http;


String s="";
String y="";

class Exit extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Exit> {


  File pickedImage;

  bool isImageLoaded = false;
  TextEditingController tx1;
  TextEditingController tx2;

  Future pickImage(String entry,String date) async {
    var tempStore = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = tempStore;
      isImageLoaded = true;
    });
    readText(entry,date);

  }
  Future<String> check(String check,String ex,String date)async {


    final String url = "http://2e27992f.ngrok.io/exit";
    var response = await http.post(url,
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json",
        },
        body: json.encode({
          "stringt":check,
          "checker":date,
          "exit":ex

        }));
    var res= jsonDecode(response.body);

    return res;



  }

  Future readText(String entry,String date) async {
    s="";

    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          s+=word.text;
          s+=" ";

        }
      }
    }
    print(s);
    print(entry.toUpperCase());


    String answer=await check(s,entry,date);

    setState(() {
      y=answer;


    });

  }


  String entryplace='';
  String date='';
  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Text("EXIT Point System",style: TextStyle(
                  fontSize: 25
              ),),
              SizedBox(height: 30.0),
              isImageLoaded
                  ? Center(
                child: Container(
                    height: 300.0,
                    width: 300.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(pickedImage)))),
              )
                  : Container(),
              SizedBox(height: 10.0),
              RaisedButton(
                  child: Text('Pick an image'),
                  onPressed: (){
                    pickImage(entryplace,date);

                  }
              ),
              SizedBox(height: 10.0),
              Container(
                height: 100,
                width: 200,
                child: TextField(
                  controller: tx1,

                  decoration: InputDecoration(
                    hintText: "Entry Place",


                  ),
                  onChanged: (value){
                    entryplace=value;

                  },
                ),
              ),
              Container(
                height: 100,
                width: 200,
                child: TextField(
                  controller: tx2,

                  decoration: InputDecoration(
                    hintText: "Date",


                  ),
                  onChanged: (value){
                    date=value;

                  },
                ),
              ),

              Container(
                child: Text("$y"),
              ),
            ],
          ),
        ));
  }
}