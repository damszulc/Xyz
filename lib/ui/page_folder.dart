import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_collections/ui/page_attachments.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';

import 'package:flutter_ui_collections/utils/utils.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui_collections/utils/utils.dart';
import 'package:flutter_ui_collections/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../LocalBindings.dart';
import 'page_single.dart';

class PageFolder extends StatefulWidget {
  @override
  final int id;
  final int parent_id;
  const PageFolder (this.id, this.parent_id);
  _PageFolderState createState() => _PageFolderState();
}

class _PageFolderState extends State<PageFolder> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void initState() {
    navigate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Dodaj folder",
            style:
            TextStyle(fontFamily: "Exo2", color: backgroundColor)),
        backgroundColor: colorCurve,
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.all(0.0),
            icon: Image.asset('assets/EKOB-1.png'),
            iconSize: 80,
            alignment: Alignment(-1.0, -1.0),

          )],
      ),
      floatingActionButton: FloatingActionButton.extended(
        hoverColor: Colors.yellow,
        onPressed: () {
          if (_formKey.currentState.validate()) {
            save_folder(widget.id, widget.parent_id, emailController.text);

            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => PageAttachments(widget.id, widget.parent_id)),
            );
          }
        },
        label: Text('Zapisz'),
        icon: Icon(Icons.save),
        backgroundColor: colorCurve,
      ),
      body: Container(
          padding: EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _emailWidget(),
                SizedBox(height: 20.0),
              ],
            ),
          )),
    );
  }

  TextFormField _emailWidget() {
    return TextFormField(
        controller: emailController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Nazwa folderu',
        ),
        obscureText: false,
        validator: (value) {
          if (value.isEmpty) {
            return 'Proszę wpisać tekst';
          }
          return null;
        });
  }

  Future<File> imageFile;
  String base64Image;
  File tmpFile;

  _openGallery(BuildContext context) async {
    var picture = ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
      //tu powinno się zapisywać do bazy
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    var picture = ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return  showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Wybierz źródło"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Galeria"),
                onTap: () {
                  _openGallery(context);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                  child: Text("Aparat"),
                  onTap: () {
                    _openCamera(context);
                  }
              )
            ],
          ),
        ),
      );
    });
  }

  String status = '';

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  save_folder(int cid, int parent_id, String fileName) {
    var data = {
      "name": fileName,
      "cid": cid,
      "parent_id": parent_id
    };
    http.post("https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=save_folder&format=raw", body: json.encode(data)).then((result) {
      print(result.body);
      setStatus(result.statusCode == 200 ? result.body : "Error");
    }).catchError((error) {
      setStatus(error);
    });
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: imageFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Flexible(
              child: Center(child: Image.file(
                snapshot.data,
                fit: BoxFit.fill,
              ),
              ));
        } else if (null != snapshot.error) {
          return const Text(
            'Wystąpił błąd',
            textAlign: TextAlign.center,
          );
        } else {
          return const Center(child: Text(
            'Nie wybrano zdjęcia',
            textAlign: TextAlign.center,
          ));
        }
      },
    );
  }

  Future navigate () async {
    String isLoggedIn = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
    if(isLoggedIn == null || isLoggedIn == "0"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}