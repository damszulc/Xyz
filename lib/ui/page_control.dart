import 'dart:io';
import 'dart:async';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_collections/LocalBindings.dart';
import 'package:flutter_ui_collections/main.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';
import 'package:flutter_ui_collections/ui/page_responsible.dart';

import 'package:flutter_ui_collections/utils/utils.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'page_single.dart';
import 'package:intl/intl.dart';

class PageControl extends StatefulWidget {
  @override
  final int id;
  final int parent_id;
  final String control_id;

  const PageControl (this.id, this.parent_id, this.control_id);
  _PageControlState createState() => _PageControlState();
}

class _PageControlState extends State<PageControl> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameFieldContoller = new TextEditingController();
  TextEditingController _descFieldContoller = new TextEditingController();
  FocusNode _nameFocusNode = new FocusNode();
  FocusNode _descFocusNode = new FocusNode();
  String _date, _name, _desc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Dodaj kontrolę",
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
            http.post(
                "https://ekob.pl/index.php?option=com_ajax&plugin=mobileapp&action=save_and_publish_control&format=raw",
                body: json.encode({
                  "cid": widget.id.toString(),
                  "id": widget.control_id.toString(),
                  "name": _nameFieldContoller.text,
                  "desc": _descFieldContoller.text,
                  "date": _date,
                  "function": _mySelection,
                  "responsible_id" : _responsible
                })).then((result) {
              print(result.body);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PageSingle(widget.id, widget.parent_id)),
              );
            });
          }
        },
        label: Text('Zapisz'),
        icon: Icon(Icons.save),
        backgroundColor: colorCurve,
      ),
      body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            Container(
            padding: EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                Row(children: <Widget> [protocolButton()]
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                     controller: _nameFieldContoller,
                     focusNode: _nameFocusNode,
                     decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nazwa', labelStyle: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")
                    ),
                  style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2"),
                  obscureText: false),
                SizedBox(
                  height: 20.0,
                ),
                _emailWidget(),
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
                                    (_date != null) ? " $_date" : "Data",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal,
                                        fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2"),
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
              responsibleButton(),
                /*Container(
                  margin: EdgeInsets.only(top: 30.0),
                  child: FutureBuilder<List<Responsible>>(
                    future: fetchResponsibles(http.Client(), widget.id, widget.control_id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      return snapshot.hasData
                          ? Column(children: <Widget> [Container(
                          margin: EdgeInsets.only(top: 15.0),
                          child: Text("Osoby odpowiedzialne",
                              style: TextStyle(
                                  fontFamily: "Exo2",
                                  fontSize: 16.0,
                                  color: colorCurveSecondary,
                                  fontWeight: FontWeight.w700))
                      ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 8.0,
                              left: 20.0,
                              right: 20.0),
                          child: Container(height: 4.0, color: colorCurveSecondary),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                            child: ResponsiblesList(responsibles: snapshot.data))])
                          : Center(child: CircularProgressIndicator());
                    },
                  ),
                )*/
                  ])),
              ],
            ),
          )),
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
        _date = DateFormat('dd.MM.yyyy').format(selectedDate).toString();
      });
  }

  TextField _emailWidget() {
    return TextField(
      controller: _descFieldContoller,
      focusNode: _descFocusNode,
      maxLines: 6,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Opis',
        labelStyle: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")
      ),
      style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2"),
      obscureText: false);
  }

  String datetime = '';
  FlatButton _dateWidget() {
    return FlatButton(
        onPressed: () {
         /* DatePicker.showDatePicker(context,
              showTitleActions: true,
              minTime: DateTime.now(),
              onChanged: (date) {
                print('change $date');
              }, onConfirm: (date) {
                print('confirm $date');
                datetime = date.toString();
                setState(() {});
              }, currentTime: DateTime.now(), locale: LocaleType.pl);
       */ },
        child: Text(
          "Ustaw datę $datetime",
          style: TextStyle(color: Colors.blue),
        ));

  }

  DropdownButton priorityButton() {
    return DropdownButton<String>(
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
  }).toList());}

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
            isExpanded: true,
            hint: new Text("Wybierz z listy", style: TextStyle(fontSize: displayWidth(context) * 0.04, fontFamily: "Exo2")),
      icon: Icon(Icons.arrow_downward),
      iconSize: 14,
      elevation: 5,
      style: TextStyle(color: Colors.black, fontSize: displayWidth(context) * 0.04),
      items: data.map((item) {
        return new DropdownMenuItem(
          child: new Text(item['value']),
          value: item['id'].toString(),

        );
      }).toList(),
      onChanged: (newVal) {
        setState(() {
          _mySelection = newVal;
          http.post(
              "https://ekob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_control_by_id&format=raw",
              body: {
                "id": newVal
              }).then((result) {
            print(result.body);
            var resBody = json.decode(result.body);
            _nameFieldContoller.text = resBody['value'];
            _descFieldContoller.text = resBody['desc'];
            setStatus(result.statusCode == 200 ? result.body : "Error");
          }).catchError((error) {
            setStatus(error);
          });
          /*Navigator.pop(
            context,
            MaterialPageRoute(builder: (context) => PageControl(widget.id, widget.parent_id)),
          );*/
        });
      },
      value: _mySelection,
    )
    )
    )
    );
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
              onChanged: (newVal) {
                setState(() {
                  _responsible = newVal;
                });
              },
              value: _responsible,
            )));
  }

  @override
  void initState() {
    navigate();
    super.initState();
    this.getProtocols(widget.id);
    this.getResponsibles(widget.id);
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
          "https://wkob.srv28629.microhost.com.pl/test.php",
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
    http.post("https://ekob.pl/index.php?option=com_ajax&plugin=mobileapp&action=save_fault&format=raw", body: json.encode(data)).then((result) {
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

  final String url = "https://ekob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_controls_type&format=raw";
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

  final String urlres = "https://ekob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_reponsibles&format=raw";
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

Future<List<Responsible>> fetchResponsibles(http.Client client, int cid, String control_id) async {
  String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
  var url = 'https://ekob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_responsibles&format=raw';
  var data = {'user_id': user_id, 'cid' : cid, 'control_id' : control_id};

  final response = await http.post(url, body: json.encode(data));
  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

  return parsed.map<Responsible>((json) => Responsible.fromJson(json)).toList();
}

class Responsible {
  final int id;
  final String field77;
  final String field78;
  final String field79;
  final String field80;

  Responsible({this.id, this.field77, this.field78, this.field79, this.field80});

  factory Responsible.fromJson(Map<String, dynamic> json) {
    return Responsible(
        id: int.parse(json['id']) as int,
        field77: json['field77'] as String,
        field78: json['field78'] as String,
        field79: json['field79'] as String,
        field80: json['field80'] as String
    );
  }
}

class ResponsiblesList extends StatelessWidget {
  Screen size;
  final List<Responsible> responsibles;

  ResponsiblesList({Key key, this.responsibles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: responsibles.length,
      itemBuilder: (context, index) {
        return propertyCard(context, responsibles[index]);
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

  _getColor(int state) {
    if(state == 1) {
      return Colors.red;
    }
    else if(state == 2) {
      return Colors.green;
    }
    else {
      return Colors.grey;
    }
  }

  Card propertyCard(BuildContext context, Responsible property) {
    return Card(
        elevation: 4.0,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        borderOnForeground: true,
        child: Container(
            width: size.getWidthPx(170),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ExpandablePanel(
                  header: Padding(padding: EdgeInsets.all(10),
                    child: Row(children: <Widget> [
                      Column(children: <Widget> [
                        Text(property.field77!=null?property.field77:"", textAlign: TextAlign.left),
                    ]),
                  ])),
                  expanded: Padding(padding: EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                        Text(property.field78!=null?property.field78:""),
                        SizedBox(height: size.getWidthPx(8)),
                        Text(property.field79!=null?property.field79:""),
                        SizedBox(height: size.getWidthPx(8)),
                        Text(property.field80!=null?property.field80:""),
                        SizedBox(height: size.getWidthPx(8))
                      ]))
              ,
            )])));
  }

}