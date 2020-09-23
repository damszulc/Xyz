import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';
import 'package:flutter_ui_collections/utils/utils.dart';
import 'package:flutter_ui_collections/widgets/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../LocalBindings.dart';
import 'page_home.dart';
import 'page_signup.dart';


class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  FocusNode _emailFocusNode = new FocusNode();
  FocusNode _passFocusNode = new FocusNode();
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Screen size;

  @override
  void initState() {
    navigate();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery
        .of(context)
        .size);

    return Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Terminarz",
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
        body: AnnotatedRegion(
          value: SystemUiOverlayStyle(
              statusBarColor: backgroundColor,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarIconBrightness: Brightness.light,
              systemNavigationBarColor: backgroundColor),

          child: Container(
            margin: EdgeInsets.only(top: size.getWidthPx(10)),
            child: FutureBuilder<List<Control>>(
              future: fetchControls(http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? Column(children: <Widget> [
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ControlsList(controls: snapshot.data))])
                    : Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ));
  }

  Future navigate () async {
    String isLoggedIn = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
    if(isLoggedIn == null || isLoggedIn == "0"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}



Future<List<Control>> fetchControls(http.Client client) async {
  String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
  var url = 'https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_calendar&format=raw';
  var data = {'user_id': user_id};

  final response = await http.post(url, body: json.encode(data));
  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

  return parsed.map<Control>((json) => Control.fromJson(json)).toList();
}

class Control {
  final int id;
  final String name;
  final String description;
  final String date;
  final String responsible;

  Control({this.id, this.name, this.description, this.date, this.responsible});

  factory Control.fromJson(Map<String, dynamic> json) {
    return Control(
        id: int.parse(json['id']) as int,
        name: json['name'] as String,
        description: json['desc'] as String,
        date: json['date'] as String,
        responsible: json['responsible'] as String
    );
  }
}

class ControlsList extends StatelessWidget {
  Screen size;
  final List<Control> controls;

  ControlsList({Key key, this.controls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return SizedBox( height: MediaQuery.of(context).size.height, child: Container( child: ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: controls.length,
      itemBuilder: (context, index) {
        return propertyCard(context, controls[index]);
      },
    )));
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

  __isResponsible(String responsible) {
    if(responsible != "") {
      return Text('Osoby odpowiedzialne: ' + responsible,
          textAlign: TextAlign.left);
    }
    else {
      return Container();
    }
  }

  Card propertyCard(BuildContext context, Control property) {
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
                    child: Column(children: <Widget> [
                      SizedBox(child:
                      leftAlignText(
                          text: property.name!=null?property.name:"",
                          leftPadding: size.getWidthPx(0),
                          textColor: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500)),
                      SizedBox(height: size.getWidthPx(8)),
                            Row(children: <Widget> [
                              Text(property.date, textAlign: TextAlign.left,)]),
                    ]),
                  ),
                  expanded: Padding(padding: EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                        Text(property.description),
                        SizedBox(height: size.getWidthPx(8)),
                        __isResponsible(property.responsible),
                      ])),
                ),
                SizedBox(height: size.getWidthPx(4)),
              ],
            )));
  }

}