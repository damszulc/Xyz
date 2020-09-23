import 'dart:ffi';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';

import 'package:flutter_ui_collections/utils/utils.dart';
import 'package:flutter_ui_collections/widgets/boxfield.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../LocalBindings.dart';
import 'page_single.dart';
import 'page_control.dart';

class PageResponsible extends StatefulWidget {
  @override
  final int id;
  final int parent_id;
  final String control_id;

  const PageResponsible (this.id, this.parent_id, this.control_id);
  _PageResponsibleState createState() => _PageResponsibleState();
}

class _PageResponsibleState extends State<PageResponsible> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameFieldContoller = new TextEditingController();
  TextEditingController _emailFieldContoller = new TextEditingController();
  TextEditingController _phoneFieldContoller = new TextEditingController();
  FocusNode _nameFocusNode = new FocusNode();
  FocusNode _emailFocusNode = new FocusNode();
  FocusNode _phoneFocusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Dodaj osobę odpowiedzialną",
            style:
            TextStyle(fontFamily: "Exo2", color: backgroundColor)),
        backgroundColor: colorCurve,
      ),
      floatingActionButton: FloatingActionButton.extended(
        hoverColor: Colors.yellow,
        onPressed: () {
          if (_formKey.currentState.validate()) {
            http.post(
                "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=save_responsible&format=raw",
                body: json.encode({
                  "cid": widget.id.toString(),
                  "control_id": widget.control_id.toString(),
                  "field77": _nameFieldContoller.text,
                  "field78": _emailFieldContoller.text,
                  "field79": _phoneFieldContoller.text,
                  "field80": _mySelection
                })).then((result) {
              print(result.body);
              var control_id = json.decode(result.body).toString();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PageControl(widget.id, widget.parent_id, widget.control_id)),
              );
            });
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => PageSingle(widget.id, widget.parent_id)),
            );
          }
        },
        label: Text('Zapisz'),
        icon: Icon(Icons.save),
        backgroundColor: colorCurve,
      ),
      body: Container(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(12),
                    child: Column(
                        children: <Widget>[
                          TextField(
                              controller: _nameFieldContoller,
                              focusNode: _nameFocusNode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Imię i nazwisko',
                              ),
                              obscureText: false),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextField(
                              controller: _emailFieldContoller,
                              focusNode: _emailFocusNode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Adres e-mail',
                              ),
                              obscureText: false),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextField(
                              controller: _phoneFieldContoller,
                              focusNode: _phoneFocusNode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Telefon',
                              ),
                              obscureText: false),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(children: <Widget> [
                            protocolButton()]
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                        ])),
              ],
            ),
          )),
    );
  }

  Padding priorityButton() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
    child: Container(
    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10.0),
    color: Colors.cyan,
    border: Border.all()),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          value: dropdownValue,
          icon: Icon(Icons.arrow_downward),
          iconSize: 14,
          elevation: 5,
          style: TextStyle(color: Colors.black),
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
            });
          },
          items: <String>['Niska', 'Normalna', 'Wysoka']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList())
    )
    )
    );
  }

  String _mySelection;
  String dropdownValue = "Normalna";
  Padding protocolButton() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: MediaQuery.of(context).size.width-24,
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Color.fromRGBO(250, 250, 250, 1),
              border: Border.all(color: Colors.black45)),
          child: DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: new Text("Funkcja"),
      icon: Icon(Icons.arrow_downward),
      iconSize: 14,
      elevation: 0,
      style: TextStyle(color: Colors.black, fontSize: 16.0),
      items: data.map((item) {
        return new DropdownMenuItem(
          child: new Text(item['value']),
          value: item['id'].toString(),
        );
      }).toList(),
      onChanged: (newVal) {
        setState(() {
          _mySelection = newVal;
        });
      },
      value: _mySelection,
    )
    )
    )
    );
  }

  @override
  void initState() {
    navigate();
    super.initState();
    this.getProtocols(widget.id);
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

  startUpload(int cid, String file_id, String priority, String field) {
    setStatus('Uploading Image...');
    if (null == tmpFile) {
      setStatus("Error");
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    upload(fileName);
    save_fault(file_id, cid, field, priority, fileName);
  }

  upload(String fileName) {
    if(base64Image != null) {
      http.post(
          "http://wkob.srv28629.microhost.com.pl/test.php",
          body: {
            "image": base64Image,
            "name": fileName,
          }).then((result) {
        print(result.body);
        setStatus(result.statusCode == 200 ? result.body : "Error");
      }).catchError((error) {
        setStatus(error);
      });
    }
  }

  save_fault(String file_id, int cid, String description, String priority, String photo) {
    var data = {
      "file_id": file_id,
      "cid": cid,
      "description" : description,
      "priority" : priority,
      "photo" : photo
    };
    print(data);
    http.post("https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=save_fault&format=raw", body: json.encode(data)).then((result) {
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
            )),
          );
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

  final String url = "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_responsible_type&format=raw";
  List data = List(); //edited line

  Future<String> getProtocols(int cid) async {
    // Starting Web API Call.
    final response = await http.post(url, body: json.encode( {'cid': cid}));
    var resBody = json.decode(response.body);

    setState(() {
      data = resBody;
    });

    print(resBody);

    return "Success";
  }

  Future navigate () async {
    String isLoggedIn = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
    if(isLoggedIn == null || isLoggedIn == "0"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
