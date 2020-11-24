import 'dart:io';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';

import 'package:flutter_ui_collections/utils/utils.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../LocalBindings.dart';
import 'page_single.dart';
import '../main.dart';

class PageFault extends StatefulWidget {
  @override
  final int id;
  final int parent_id;
  final String fault_id;

  const PageFault (this.id, this.parent_id, this.fault_id);
  _PageFaultState createState() => _PageFaultState();
}

class _PageFaultState extends State<PageFault> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _titleFieldController = TextEditingController();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _titleFocusNode = FocusNode();
  String _description;
  String _date;
  String _remove_date;

  @override
  void initState() {
    getFault();
    setState(() {

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text((_titleFieldController.text==''?"Dodaj usterkę":"Edytuj usterkę"),
            style:
            TextStyle(fontFamily: "Exo2", color: backgroundColor, fontSize: displayWidth(context) * 0.05)),
        leading: new Container(child: BackButton(
          color: Colors.white, onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageSingle(widget.id, widget.parent_id)),
          );
        },
        )),
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
            save_fault(int.parse(widget.fault_id), _mySelection, _nameFieldController.text, dropdownValue, _titleFieldController.text, true);
          }
        },
        label: Text('Zapisz', style: TextStyle(fontSize: displayWidth(context) * 0.033, fontFamily: "Exo2")),
        icon: Icon(Icons.save),
        backgroundColor: colorCurve,
      ),
      body: SingleChildScrollView(child: Container(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            Container(
            padding: EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                protocolButton(),
                SizedBox(
                  height: 20.0,
                ),
                titleButton(),
                SizedBox(
                  height: 20.0,
                ),
                _nameField(),
                SizedBox(
                  height: 20.0,
                ),
                priorityButton(),
                SizedBox(
                  height: 20.0,
                ),
                stateButton(),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(color: Colors.grey)),
                  elevation: 0,
                  onPressed: () {
                    _selectDate(context);
                    },
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    (_remove_date != null) ? " $_remove_date" : "Data usunięcia usterki",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: "Exo2",
                                        fontSize: displayWidth(context) * 0.04),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Icon(Icons.arrow_downward, size: 14),
                      ],
                    ),
                  ),
                  color: Color.fromRGBO(250, 250, 250, 1),
                ),
                SizedBox(
                  height: 20.0,
                ),
                responsibleButton()
                ])),
                //showImage(widget.fault_id),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
                    child: Center(
                        child: Container(
                            width: 180.0,
                            child: RaisedButton(
                              onPressed: () {
                                save_fault(int.parse(widget.fault_id), _mySelection, _nameFieldController.text, dropdownValue, _titleFieldController.text, false);
                                _showChoiceDialog(context);
                              },
                      highlightColor: Colors.yellow,
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(22.0)),
                      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                      child: Center(child: Text(
                        'Dodaj zdjęcie',
                        style: TextStyle(
                            fontFamily: 'Exo2', color: Colors.white, fontSize: displayWidth(context) * 0.033),
                      )),
                      color: colorCurveSecondary,

                    )))),
                Container(
                  margin: EdgeInsets.only(top: 30.0),
                  child: FutureBuilder<List<Photo>>(
                    future: fetchPhotos(http.Client(), int.parse(widget.fault_id)),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      return snapshot.hasData
                          ? Column(children: <Widget> [
                        PhotosList(photos: snapshot.data)]) : Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ))),
    );
  }
  DateTime selectedDate = DateTime.now();

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025)
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _remove_date = DateFormat('dd.MM.yyyy').format(selectedDate).toString();
    });
  }

  getFault() {
    print("+++++++++++++++++++++++++++++++++++++++++++++++++");
    http.post(
        "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_fault_by_id&format=raw",
        body: {
          "id": widget.fault_id
        }).then((result) {

      var resBody = json.decode(result.body);
      if(resBody['title'] != "") _titleFieldController.text = resBody['title'];
      if(resBody['description'] != "") _nameFieldController.text = resBody['description'];
      if(resBody['file_id'] != "") _mySelection = resBody['file_id'];
      if(resBody['priority'] != "") dropdownValue = resBody['priority'];
      if(resBody['state'] != "") stateValue = resBody['state'];
      if(resBody['remove_date'] != "") _remove_date = resBody['remove_date'];
      if(resBody['responsible_id'] != "") _responsible = resBody['responsible_id'];
      setStatus(result.statusCode == 200 ? result.body : "Error");
    }).catchError((error) {
      setStatus(error);
    });
  }

  TextField titleButton() {
    return TextField(
        controller: _titleFieldController,
        focusNode: _titleFocusNode,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Tytuł',
          labelStyle: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")
        ),
        obscureText: false,
        style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")
    );
  }

  TextField _nameField() {
    return TextField(
      controller: _nameFieldController,
        focusNode: _nameFocusNode,
        maxLines: 5,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Opis',
          labelStyle: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2"),
        ),
        obscureText: false,
        style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")
    );
  }

  String stateValue = "Nowa";
  Container stateButton() {
    return Container(
        width: MediaQuery.of(context).size.width-24,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Color.fromRGBO(250, 250, 250, 1),
            border: Border.all(color: Colors.black45)),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                isExpanded: true,
                hint: new Text("Status usterki", style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")),
                icon: Icon(Icons.arrow_downward),
                iconSize: 14,
                elevation: 5,
                style: TextStyle(color: Colors.black, fontSize: displayWidth(context) * 0.04),
                onChanged: (String newValue) {
                  setState(() {
                    stateValue = newValue;
                  });
                },
                value: stateValue,
                items: <String>['Nowa', 'Przydzielona', 'Wykonana - do sprawdzenia', 'Zatwierdzona']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")),
                  );
                }).toList())));
  }

  String dropdownValue = "Normalna";
  Container priorityButton() {
    return Container(
        width: MediaQuery.of(context).size.width-24,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Color.fromRGBO(250, 250, 250, 1),
            border: Border.all(color: Colors.black45)),
        child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
        isExpanded: true,
        hint: new Text("Ważność usterki", style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")),
        icon: Icon(Icons.arrow_downward),
        iconSize: 14,
        elevation: 5,
        style: TextStyle(color: Colors.black, fontSize: displayWidth(context) * 0.04),
  onChanged: (String newValue) {
  setState(() {
  dropdownValue = newValue;
  });
  },
  value: dropdownValue,
  items: <String>['Niska', 'Normalna', 'Wysoka', 'Monitoring usterki']
      .map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(
  value: value,
  child: Text(value, style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")),
  );
  }).toList())));
  }

  String _mySelection;
  Container protocolButton() {
    if(stateValue!="Nowa") {
      return Container(
          width: MediaQuery
              .of(context)
              .size
              .width - 24,
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Color.fromRGBO(250, 250, 250, 1),
              border: Border.all(color: Colors.black45)),
          child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                hint: new Text("Protokół", style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")),
                icon: Icon(Icons.arrow_downward),
                iconSize: 14,
                elevation: 5,
                style: TextStyle(color: Colors.black, fontSize: displayWidth(context) * 0.04),
                items: data.map((item) {
                  return new DropdownMenuItem(
                    child: new Text(item['filename']),
                    value: item['id'].toString(),

                  );
                }).toList(),
                onChanged: (newVal) {
                  setState(() {
                    _mySelection = newVal;
                  });
                },
                value: _mySelection,
              )));
    }
    else return Container();
    }

  String _responsible;
  Container responsibleButton() {
    return Container(
        width: MediaQuery.of(context).size.width-24,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Color.fromRGBO(250, 250, 250, 1),
            border: Border.all(color: Colors.black45)),
        child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              hint: new Text("Osoba odpowiedzialna", style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")),
              icon: Icon(Icons.arrow_downward),
              iconSize: 14,
              elevation: 5,
              style: TextStyle(color: Colors.black, fontSize: displayWidth(context) * 0.04),
              items: responsibles.map((item) {
                return new DropdownMenuItem(
                  child: new Text(item['name']),
                  value: item['id'].toString(),
                );
              }).toList(),
              isDense: false,
              onChanged: (newVal) {
                setState(() {
                  _responsible = newVal;
                });
              },
              value: _responsible
            )));
  }
  
  Future<File> imageFile;
  String base64Image;
  File tmpFile;

  _openGallery(BuildContext context, String fault_id) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 90, maxHeight: 1280, maxWidth: 1280);
    this.setState(() {
      base64Image = base64Encode(picture.readAsBytesSync());
      startUpload(fault_id, picture.path);
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context, String fault_id) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 90, maxHeight: 1280, maxWidth: 1280);
    this.setState(() {
      base64Image = base64Encode(picture.readAsBytesSync());
      startUpload(fault_id, picture.path);
    });
    Navigator.of(context).pop();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Wybierz źródło"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Galeria"),
                onTap: () {
                  _openGallery(context, widget.fault_id);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                  child: Text("Aparat"),
                  onTap: () {
                    _openCamera(context, widget.fault_id);
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

  startUpload(String fault_id, String imagePath) {
    setStatus('Uploading Image...');
    String fileName;
    fileName = imagePath
          .split('/')
          .last;
      save_fault_photo(fault_id, fileName);
      upload(fileName, fault_id);
  }

  upload(String fileName, String fault_id) {
    if (base64Image != null) {
      http.post(
          "https://wkob.srv28629.microhost.com.pl/test.php",
          body: {
            "image": base64Image,
            "name": fileName,
          }).then((result) {
        setStatus(result.statusCode == 200 ? result.body : "Error");
       // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PageFault(350, 0, fault_id)));
      }).catchError((error) {
        setStatus(error.toString());
      });
    }
  }

  save_fault(int id, String file_id, String description, String priority, String title, bool redirect) {
    var data = {
      "id" : id,
      "file_id": file_id,
      "description" : description,
      "priority" : priority,
      "state" : stateValue,
      "date" : _date,
      "remove_date" : _remove_date,
      "responsible_id" : _responsible,
      "title" : title
    };

    http.post("https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=save_fault&format=raw", body: json.encode(data))
        .then((result) {
      setStatus(result.statusCode == 200 ? result.body : "Error");
      if(redirect == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PageSingle(widget.id, widget.parent_id)),
        );
      }
    }).catchError((error) {
     // setStatus(error);
    });
  }

  save_fault_photo(String fault_id, String photo) {
    var data = {
      "fault_id": fault_id,
      "photo": photo
    };
    http.post(
        "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=save_fault_photo&format=raw",
        body: json.encode(data)).then((result) {
      setStatus(result.statusCode == 200 ? result.body : "Error");
    }).catchError((error) {
      setStatus(error);
    });
  }

  Widget showImage(String fault_id) {
    return FutureBuilder<File>(
      future: imageFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
         // startUpload(fault_id);
          return Container(
            height: 220,
            child: Center(child: Image.file(
              snapshot.data,
              height: 200,
              fit: BoxFit.scaleDown
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

  final String url = "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_protocols&format=raw";
  List data = List(); //edited line

  Future<String> getProtocols(int cid) async {
    // Starting Web API Call.
    final response = await http.post(url, body: json.encode( {'cid': cid}));
    var resBody = json.decode(response.body);

    setState(() {
      data = resBody;
    });
    return "Success";
  }

  final String urlres = "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_reponsibles&format=raw";
  List responsibles = List(); //edited line

  Future<String> getResponsibles(int cid) async {
    // Starting Web API Call.
    final response = await http.post(urlres, body: json.encode( {'cid': cid}));
    var resBody = json.decode(response.body);
    setState(() {
      responsibles = resBody;
    });

    return "Success";
  }

  Future navigate () async {
    String isLoggedIn = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
    if(isLoggedIn == null || isLoggedIn == "0"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}

Future<List<Photo>> fetchPhotos(http.Client client, int fault_id) async {
  String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
  var url = 'https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_photos&format=raw';
  var data = {'user_id': user_id, 'fault_id' : fault_id};

  final response = await http.post(url, body: json.encode(data));
  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class Photo {
  final int id;
  final String src;

  Photo({this.id, this.src});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
        id: int.parse(json['id']) as int,
        src: json['src'] as String
    );
  }
}

class PhotosList extends StatelessWidget {
  Screen size;
  final List<Photo> photos;

  PhotosList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return GridView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemBuilder: (context, index) {
        return propertyCard(context, photos[index]);
      },
    );
  }

  Padding leftAlignText({text, leftPadding, textColor, fontSize, fontWeight}) {
    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text??"",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: 'Exo2',
                fontSize: fontSize,
                fontWeight: fontWeight ?? FontWeight.w500,
                color: textColor)),
      ),
    );
  }

  Card propertyCard(BuildContext context, Photo property) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      borderOnForeground: true,
      child: Container(
          width: size.getWidthPx(170),
          child: InkWell(
              onTap: (){ launch('https://wkob.srv28629.microhost.com.pl/uploads/'+ property.src); },
          child: CachedNetworkImage(
            imageUrl: 'https://wkob.srv28629.microhost.com.pl/uploads/thumbs/'+ property.src,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
      ),
    ));
  }

}