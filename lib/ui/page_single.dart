import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_collections/ui/page_attachments.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';
import 'package:flutter_ui_collections/ui/page_webview.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_ui_collections/utils/utils.dart';
import 'package:flutter_ui_collections/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../LocalBindings.dart';
import 'page_home.dart';
import 'page_attachments.dart';
import 'page_fault.dart';
import 'page_control.dart';
import 'page_webview.dart';
import 'flutter_notifications.dart';

Future<Object> getObject(http.Client client, int cid) async {
  String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);

  var url = 'https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_single&format=raw';
  var data = {'user_id': user_id, 'cid': cid};

  // Starting Web API Call.
  final response = await http.post(url, body: json.encode(data));
  return Object.fromJson(jsonDecode(response.body));
}

class Object {
  final int id;
  final String name;
  final String type;
  final String location;
  final String image;
  final int fum;
  final int cum;
  final int st;
  final String access_code;

  Object({this.id, this.name, this.type, this.location, this.image, this.fum, this.cum, this.st, this.access_code});

  factory Object.fromJson(Map json) {
    return Object(
        id: int.parse(json['id']) as int,
        name: json['name'] as String,
        type: json['type'] as String,
        location: json['location'] as String,
        image: json['image'] as String,
        fum: int.parse(json['fum']) as int,
        cum: int.parse(json['cum']) as int,
        st: int.parse(json['st']) as int,
        access_code: json['access_code'] as String
    );
  }
}

class PageSingle extends StatefulWidget {
  @override
  final int id;
  final int parent_id;
  const PageSingle (this.id, this.parent_id);
  _PageComingSoonState createState() => _PageComingSoonState();
}

class _PageComingSoonState extends State<PageSingle> {
  Screen size;

  @override
  void initState() {
    navigate();
    super.initState();
    this.getUserGroup();
  }

  String user_group;
  String user_id;
  Future<String> getUserGroup() async {
   // setState(() {
      user_group = await LocalStorage.sharedInstance.readValue(Constants.userGroup);
      print(user_group);
      user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
   // });

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery
        .of(context)
        .size);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Podgląd obiektu",
              style:
              TextStyle(fontFamily: "Exo2", color: backgroundColor)),
          backgroundColor: colorCurve,
          automaticallyImplyLeading: false,
          leading: new Container(child: BackButton(
            color: Colors.white, onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          )),
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.all(0.0),
              icon: Image.asset('assets/EKOB-1.png'),
              iconSize: 80,
              alignment: Alignment(-1.0, -1.0),

            )],
        ),
        body: FutureBuilder<Object>(
          future: getObject(http.Client(), widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? ObjectInstance(
              object: snapshot.data, parent_id: widget.parent_id, user_group: user_group, user_id: user_id)
                : Center(child: CircularProgressIndicator());
          },
        )
    );
  }

  Future navigate() async {
    String isLoggedIn = await LocalStorage.sharedInstance.readValue(
        Constants.isLoggedIn);
    if (isLoggedIn == null || isLoggedIn == "0") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}

class ObjectInstance extends StatelessWidget {
  Screen size;
  final Object object;
  final int parent_id;
  final String user_group;
  final String user_id;

  ObjectInstance({Key key, this.object, this.parent_id, this.user_group, this.user_id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery
        .of(context)
        .size);
    return Container(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            children: <Widget>[upperPart(context, object, parent_id)],
          ),
        ),
        );
  }

  _checkButtons1 (BuildContext context, Object object, int parent_id)  {
    if(user_group!='USER') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          faultWidget(context, object, parent_id),
          controlWidget(context, object, parent_id),
        ],
      );
    }
    else return Row();
  }
  _checkButtons2(BuildContext context, Object object, int parent_id) {
    if(user_group!='USER') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          attachmentWidget(context, object, parent_id)
        ],
      );
    }
    else return Row();
  }

  Widget upperPart(BuildContext context, Object object, int parent_id) {
    final usterki_key = new GlobalKey();
    final kontrole_key = new GlobalKey();

    return Stack(children: <Widget>[
      ClipPath(
        clipper: UpperClipper(),
        child: Container(
          height: size.getWidthPx(150),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorCurve, colorCurve],
            ),
          ),
        ),
      ),
      Column(
        children: <Widget>[
          imageWidget(object),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              followersWidget(usterki_key, context, object),
              nameWidget(object),
              likeWidget(kontrole_key, object),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                top: size.getWidthPx(8),
                left: size.getWidthPx(20),
                right: size.getWidthPx(20)),
            child: Container(height: size.getWidthPx(4), color: colorCurve),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container (
                  margin: EdgeInsets.only(top: size.getWidthPx(10)),
                  child: buttonWidget(context, object, parent_id)
              ),
            ],
          ),
          _checkButtons1(context, object, parent_id),
          _checkButtons2(context, object, parent_id),
          Container(
            key: usterki_key,
            margin: EdgeInsets.only(top: size.getWidthPx(30)),
            child: FutureBuilder<List<Fault>>(
              future: fetchFaults(http.Client(), object.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? Column(children: <Widget> [Container(
                    margin: EdgeInsets.only(top: size.getWidthPx(15)),
                    child: Text("Usterki",
                        style: TextStyle(
                            fontFamily: "Exo2",
                            fontSize: 16.0,
                            color: colorCurve,
                            fontWeight: FontWeight.w700))
                ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: size.getWidthPx(8),
                        left: size.getWidthPx(20),
                        right: size.getWidthPx(20)),
                    child: Container(height: size.getWidthPx(4), color: colorCurve),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                    child: FaultsList(faults: snapshot.data, user_group: user_group, user_id: user_id))])
                    : Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Container(
            key: kontrole_key,
            margin: EdgeInsets.only(top: size.getWidthPx(30)),
            child: FutureBuilder<List<Control>>(
              future: fetchControls(http.Client(), object.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? Column(children: <Widget> [Container(
                    margin: EdgeInsets.only(top: size.getWidthPx(15)),
                    child: Text("Kontrole",
                        style: TextStyle(
                            fontFamily: "Exo2",
                            fontSize: 16.0,
                            color: colorCurveSecondary,
                            fontWeight: FontWeight.w700))
                ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: size.getWidthPx(8),
                        left: size.getWidthPx(20),
                        right: size.getWidthPx(20)),
                    child: Container(height: size.getWidthPx(4), color: colorCurveSecondary),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      child: ControlsList(controls: snapshot.data))])
                    : Center(child: CircularProgressIndicator());
              },
            ),
          ),
         /* Container(
            margin: EdgeInsets.only(top: size.getWidthPx(30)),
            child: FutureBuilder<List<Attachment>>(
              future: fetchAttachments(http.Client(), object.id, parent_id),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? Column(children: <Widget> [Container(
                    margin: EdgeInsets.only(top: size.getWidthPx(15)),
                    child: Text("Załączniki",
                        style: TextStyle(
                            fontFamily: "Exo2",
                            fontSize: 16.0,
                            color: colorCurveSecondary,
                            fontWeight: FontWeight.w700))
                ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: size.getWidthPx(8),
                        left: size.getWidthPx(20),
                        right: size.getWidthPx(20)),
                    child: Container(height: size.getWidthPx(4), color: colorCurveSecondary),
                  ),
                  _isBackButton(parent_id), AttachmentsList(attachments: snapshot.data)])
                    : Center(child: CircularProgressIndicator());
              },
            ),
          ),*/
        //  PhotosList()
        ],
      )
    ]);
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

  Container attachmentWidget(context, object, parent_id) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: size.getWidthPx(0), horizontal: size.getWidthPx(12)),
      child: RaisedButton(
        highlightColor: Colors.yellow,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(22.0)),
        padding: EdgeInsets.symmetric(vertical: size.getWidthPx(2), horizontal: size.getWidthPx(25)),
        child: Text(
          "Załączniki",
          style: TextStyle(
              fontFamily: 'Exo2', color: Colors.white, fontSize: 14.0),
        ),
        color: colorCurveSecondary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageAttachments(object.id, 0)),
          );
        },
      ),
    );
  }

  Container buttonWidget(context, object, parent_id) {
    print('https://wkob.pl/index.php?option=com_kob&layout=single&cid='+object.id.toString()+'&mobile_code='+object.access_code+'&tmpl=component');
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: size.getWidthPx(0), horizontal: size.getWidthPx(12)),
      child: RaisedButton(
        highlightColor: Colors.yellow,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(22.0)),
        padding: EdgeInsets.symmetric(vertical: size.getWidthPx(2), horizontal: size.getWidthPx(25)),
        child: Text(
          "Zobacz obiekt",
          style: TextStyle(
              fontFamily: 'Exo2', color: Colors.white, fontSize: 14.0),
        ),
        color: colorCurveSecondary,
       onPressed: () {
          String url = 'https://wkob.pl/index.php?option=com_kob&layout=single&cid='+object.id.toString()+'&mobile_code='+object.access_code+'&tmpl=component';
          Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => PageWebview(url)),
       );}
      ),
    );
  }
  
  Container faultWidget(context, object, parent_id) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: size.getWidthPx(0), horizontal: size.getWidthPx(12)),
      child: RaisedButton(
        highlightColor: Colors.yellow,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(22.0)),
        padding: EdgeInsets.symmetric(vertical: size.getWidthPx(2), horizontal: size.getWidthPx(25)),
        child: Text(
          "Dodaj usterkę",
          style: TextStyle(
              fontFamily: 'Exo2', color: Colors.white, fontSize: 14.0),
        ),
        color: colorCurve,
        onPressed: () {
          http.post(
              "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=save_empty_fault&format=raw",
              body: {
                "cid": object.id.toString()
              }).then((result) {
            var fault_id = json.decode(result.body).toString();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PageFault(object.id, parent_id, fault_id)),
            );
          });
        },
      ),
    );
  }

  Container controlWidget(context, object, parent_id) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: size.getWidthPx(0), horizontal: size.getWidthPx(12)),
      child: RaisedButton(
        highlightColor: Colors.yellow,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(22.0)),
        padding: EdgeInsets.symmetric(vertical: size.getWidthPx(2), horizontal: size.getWidthPx(25)),
        child: Text(
          "Dodaj kontrolę",
          style: TextStyle(
              fontFamily: 'Exo2', color: Colors.white, fontSize: 14.0),
        ),
        color: colorCurve,
        onPressed: () {
          http.post(
              "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=save_empty_control&format=raw",
              body: {
                "cid": object.id.toString()
              }).then((result) {
            print(result.body);
            var control_id = json.decode(result.body).toString();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PageControl(object.id, parent_id, control_id)),
            );
          });


        },
      ),
    );
  }

  Align imageWidget(Object object) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(top: size.getWidthPx(40)),
        child: CircleAvatar(
          foregroundColor: backgroundColor,
          maxRadius: size.getWidthPx(70),
          backgroundColor: Colors.white,
          child: CircleAvatar(
            maxRadius: size.getWidthPx(68),
            foregroundColor: colorCurve,
            backgroundImage: NetworkImage(
                object.image)
          ),
        ),
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


  Column likeWidget(GlobalKey kontrole_key, Object object) {
    return Column(
      children: <Widget>[
        new FlatButton (
            onPressed: () => Scrollable.ensureVisible(kontrole_key.currentContext),
            child: Column(
                children: <Widget>[
                  Text(object.cum.toString(),
                      style: TextStyle(
                          fontFamily: "Exo2",
                          fontSize: 16.0,
                          color: _getColor(object.st),
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: size.getWidthPx(4)),
                  Text("kontroli",
                      style: TextStyle(
                          fontFamily: "Exo2",
                          fontSize: 14.0,
                          color: _getColor(object.st),
                          fontWeight: FontWeight.w500))
                ]
            )
        ),

      ],
    );
  }

  Column nameWidget(Object object) {
    return Column(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top: size.getWidthPx(15)),
            child: SizedBox(width: 180, child: Text(object.name,
            style: TextStyle(
                fontFamily: "Exo2",
                fontSize: 16.0,
                color: colorCurve,
                fontWeight: FontWeight.w700),
            overflow: TextOverflow.clip, textAlign: TextAlign.center,)
        )),
        SizedBox(height: size.getWidthPx(4)),
        SizedBox(width: 180, child: Text(object.type,
            style: TextStyle(
                fontFamily: "Exo2",
                fontSize: 14.0,
                color: textSecondary54,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.clip,
          textAlign: TextAlign.center,)
        )],
    );
  }

  Column followersWidget(GlobalKey usterki_key, BuildContext context, Object object) {
    return Column(
      children: <Widget>[
        new FlatButton (
          onPressed: () => Scrollable.ensureVisible(usterki_key.currentContext),
          child: Column(
              children: <Widget>[
                Text(object.fum.toString(),
                  style: TextStyle(
                      fontFamily: "Exo2",
                      fontSize: 16.0,
                      color: textSecondary54,
                      fontWeight: FontWeight.w700)),
                SizedBox(height: size.getWidthPx(4)),
                Text("usterek",
                    style: TextStyle(
                        fontFamily: "Exo2",
                        fontSize: 14.0,
                        color: textSecondary54,
                        fontWeight: FontWeight.w500))
                ]
          )
        ),

      ],
    );
  }


}

Future<List<Attachment>> fetchAttachments(http.Client client, int cid, int parent_id) async {
  String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
  var url = 'https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_attachments&format=raw';
  var data = {'user_id': user_id, 'cid' : cid, 'parent_id': parent_id};

  // Starting Web API Call.
  final response = await http.post(url, body: json.encode(data));
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseAttachments, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Attachment> parseAttachments(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Attachment>((json) => Attachment.fromJson(json)).toList();
}

class Attachment {
  final int id;
  final String name;
  final String link;
  final int is_dir;
  final int cid;

  Attachment({this.id, this.name, this.link, this.is_dir, this.cid});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
        id: int.parse(json['id']) as int,
        name: json['name'] as String,
        link: json['link'] as String,
        is_dir: int.parse(json['is_dir']) as int,
        cid: int.parse(json['cid']) as int
    );
  }
}

class AttachmentsList extends StatelessWidget {
  Screen size;
  final List<Attachment> attachments;

  AttachmentsList({Key key, this.attachments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return GridView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        if(attachments[index].is_dir == 1)
          return folderCard(context, attachments[index]);
        else
          return propertyCard(context, attachments[index]);
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

  InkWell folderCard(BuildContext context, Attachment property) {
    return InkWell(
        onDoubleTap: (){ Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageAttachments(property.cid, property.id)),
        ); },
        child: Card(
            elevation: 4.0,
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            borderOnForeground: true,
            child: Container(
                height: size.getWidthPx(170),
                width: size.getWidthPx(170),
                padding: EdgeInsets.only(top: size.getWidthPx(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: size.getWidthPx(8)),
                    ClipRRect(
                        child:  new Image(image: AssetImage("assets/folder-blue.png"), height: size.getWidthPx(32))),
                    SizedBox(height: size.getWidthPx(5)),
                    Center(child: Text(property.name, textScaleFactor: 0.8, textAlign: TextAlign.center,)),
                  ],
                ))));
  }

  InkWell propertyCard(BuildContext context, Attachment property) {
    return InkWell(
        onTap: (){ launch('http://wkob.srv28629.microhost.com.pl/uploads/'+property.link); },
        child: Card(
            elevation: 4.0,
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            borderOnForeground: true,
            child: SizedBox(
                height: size.getWidthPx(170),
                width: size.getWidthPx(170),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: size.getWidthPx(8)),
                    ClipRRect(
                      child: new Image(image: AssetImage("assets/file.png"), height: size.getWidthPx(32))),
                    SizedBox(height: size.getWidthPx(5)),
                    Center(child: Padding(padding: EdgeInsets.all(5.0), child: Text(property.name, textScaleFactor: 0.8, textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,))),
                  ],
                ))));
  }

}

Future<List<Fault>> fetchFaults(http.Client client, int cid) async {
  String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
  var url = 'https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_faults&format=raw';
  var data = {'user_id': user_id, 'cid' : cid};

  final response = await http.post(url, body: json.encode(data));
  print(response);
  final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();

  return parsed.map<Fault>((json) => Fault.fromJson(json)).toList();
}

class Fault {
  final int id;
  final int object_id;
  final String title;
  final String description;
  final String priority;
  final String photo;
  final String filename;
  final String date;
  final String state;
  final String responsible;
  final String remove_date;

  Fault({this.id, this.object_id, this.title, this.description, this.priority, this.photo, this.filename, this.date, this.state, this.responsible, this.remove_date});

  factory Fault.fromJson(Map<String, dynamic> json) {
    return Fault(
        id: int.parse(json['id']) as int,
        object_id: int.parse(json['cid']) as int,
        title: json['title'] as String,
        description: json['description'] as String,
        priority: json['priority'] as String,
        photo: json['photo_src'] as String,
        filename: json['filename'] as String,
        date: json['date'] as String,
        state: json['state'] as String,
        responsible: json['responsible'] as String,
        remove_date: json['remove_date'] as String
    );
  }
}

class FaultsList extends StatelessWidget {
  Screen size;
  final List<Fault> faults;
  final String user_group;
  final String user_id;

  FaultsList({Key key, this.faults, this.user_group, this.user_id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: faults.length,
      itemBuilder: (context, index) {
          return propertyCard(context, faults[index], user_id);
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

  _showImage(String image) {
    print(image);
    if(image != null) {
      print(image);
      return Padding(
        child: Image.network(image, width: 60, alignment: Alignment.centerLeft,),
        padding: EdgeInsets.only(right: 20)
      );
    }
    else {
      return Container();
    }
  }

  _getColor(String state, DateTime data) {
    if((state == "Nowa" || state == 'Przydzielona') && (data.difference(DateTime.now()).inDays < 0)) {
      return Colors.red;
    }
    else if(state == "Wykonana - do sprawdzenia" || state == 'Zatwierdzona') {
      return Colors.green;
    }
    else {
      return Colors.grey;
    }
  }

  _checkEditButton(BuildContext context, Fault property, String user_id) {
    if(user_group == 'COORD' || user_group == 'CONTROL') {
      return RaisedButton(
        highlightColor: Colors.yellow,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(22.0)),
        padding: EdgeInsets.symmetric(vertical: size.getWidthPx(2), horizontal: size.getWidthPx(25)),
        child: Text(
          "Edytuj",
          style: TextStyle(
              fontFamily: 'Exo2', color: Colors.white, fontSize: 14.0),
        ),
        color: colorCurveSecondary,
        onPressed: () {
          print(property.id.toString());
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PageFault(property.object_id, 0, property.id.toString())),
          );
        },
      );
    }
    else if(user_group == 'USER' && property.state == 'assigned') {
      return RaisedButton(
        highlightColor: Colors.yellow,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(22.0)),
        padding: EdgeInsets.symmetric(vertical: size.getWidthPx(2), horizontal: size.getWidthPx(25)),
        child: Text(
          "Oznacz jako wykonane",
          style: TextStyle(
              fontFamily: 'Exo2', color: Colors.white, fontSize: 14.0),
        ),
        color: colorCurveSecondary,
        onPressed: () {
          _showDoneDialog(context, property, user_id);
        },
      );
    }
    else return Container();
  }

  _checkRemoveButton(BuildContext context, Fault property) {
      if(user_group == 'COORD' || user_group == 'CONTROL') {
          return RaisedButton(
            highlightColor: Colors.yellow,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(22.0)),
            padding: EdgeInsets.symmetric(vertical: size.getWidthPx(2), horizontal: size.getWidthPx(25)),
            child: Text(
              "Usuń",
              style: TextStyle(
              fontFamily: 'Exo2', color: Colors.white, fontSize: 14.0),
            ),
            color: Colors.red,
            onPressed: () {
              _showRemoveDialog(context, property);
            },
          );
      }
      else return Container();
  }

  Card propertyCard(BuildContext context, Fault property, String user_id) {
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
                        child: Column(children: <Widget>[
                          SizedBox(child:
                              leftAlignText(
                                  text: property.title!=null?property.title:"",
                                  leftPadding: size.getWidthPx(0),
                                  textColor: _getColor(property.state, DateTime.parse(property.remove_date)),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500)),
                                  SizedBox(height: size.getWidthPx(8)),
                                  Row(children: <Widget> [
                                    Text('Data usunięcia: '+(property.remove_date!="0000-00-00 00:00:00"?property.remove_date:'-brak-'), textAlign: TextAlign.left,)])])
                        ),
                  expanded: Padding(padding: EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                        leftAlignText(
                            text: property.description,
                            leftPadding: size.getWidthPx(0),
                            textColor: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                        SizedBox(height: size.getWidthPx(8)),
                        leftAlignText(
                            text: 'Data ostatniej modyfikacji: '+property.date,
                            leftPadding: size.getWidthPx(0),
                            textColor: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                        SizedBox(height: size.getWidthPx(4)),
                        leftAlignText(
                            text: 'Status usterki: '+property.state,
                            leftPadding: size.getWidthPx(0),
                            textColor: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                        SizedBox(height: size.getWidthPx(4)),
                        leftAlignText(
                            text: 'Osoba odpowiedzialna: '+(property.responsible!=""?property.responsible:'-brak-'),
                            leftPadding: size.getWidthPx(0),
                            textColor: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                        SizedBox(height: size.getWidthPx(4)),
                        Container(
                          margin: EdgeInsets.only(top: size.getWidthPx(30)),
                          child: FutureBuilder<List<Photo>>(
                            future: fetchPhotos(http.Client(), property.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) print(snapshot.error);
                              return snapshot.hasData
                                  ? Column(children: <Widget> [
                                PhotosList(photos: snapshot.data)]) : Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                        Container(margin: EdgeInsets.only(top: 20),
                            width: 210, child: Center(child: Row(children: <Widget>[
                          _checkEditButton(context, property, user_id),
                          SizedBox(width: 10),
                          _checkRemoveButton(context, property)],)))
                      ])),
                ),
                    SizedBox(height: size.getWidthPx(4)),
                  ],
                )));
  }

  Future<void> _showDoneDialog(BuildContext context, Fault property, String user_id) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Czy na pewno chcesz oznaczyć usterkę jako wykonaną?"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Tak"),
                onTap: () {
                  print("tap");
                  //tutaj zmieniamy status usterki na wykonane
                  completeFault(context, property, user_id);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                  child: Text("Nie"),
                  onTap: () {
                    //tutaj nic nie robimy
                    Navigator.of(context).pop();
                  }
              )
            ],
          ),
        ),
      );
    });
  }

  Future<void> _showRemoveDialog(BuildContext context, Fault property) {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Czy na pewno chcesz usunąć usterkę?"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Text("Tak"),
                onTap: () {
                  //tutaj usuwamy usterkę
                  print("------------------remove-------------");
                  removeFault(context, property.object_id, property.id);
                },
              ),
              Padding(padding: EdgeInsets.all(8.0)),
              GestureDetector(
                  child: Text("Nie"),
                  onTap: () {
                    //tutaj nic nie robimy
                    Navigator.of(context).pop();
                  }
              )
            ],
          ),
        ),
      );
    });
  }
}

completeFault (BuildContext context, Fault property, String user_id) async {
  await http.post(
      "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=complete_fault&format=raw",
      body: {
        "fault_id": property.id.toString(),
        "user_id": user_id
      }).then((result) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PageSingle(property.object_id, 0)),
    );
  });
}


removeFault (BuildContext context, int cid, int fault_id) async {
  await http.post(
      "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=remove_fault&format=raw",
      body: {
        "fault_id": fault_id.toString()
      });
  Navigator.push(
    context,
  MaterialPageRoute(builder: (context) => PageSingle(cid, 0)),
  );
}

Future<List<Control>> fetchControls(http.Client client, int cid) async {
  String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
  var url = 'https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_controls&format=raw';
  var data = {'user_id': user_id, 'cid' : cid};

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
  final int priority;

  Control({this.id, this.name, this.description, this.date, this.responsible, this.priority});

  factory Control.fromJson(Map<String, dynamic> json) {
    return Control(
        id: int.parse(json['id']) as int,
        name: json['field51'] as String,
        description: json['field52'] as String,
        date: json['field72'] as String,
        responsible: json['responsible'] as String,
        priority: int.parse(json['status']) as int
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
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: controls.length,
      itemBuilder: (context, index) {
        return propertyCard(context, controls[index]);
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
                    child: Column(
                        children: <Widget> [
                          SizedBox(child:
                          leftAlignText(
                              text: property.name!=null?property.name:"",
                              leftPadding: size.getWidthPx(0),
                              textColor: _getColor(property.priority),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500)),
                          SizedBox(height: size.getWidthPx(8)),
                      Row(children: <Widget> [
                        Text('Data kontroli:'+property.date, textAlign: TextAlign.left,)])
                    ]),
                  ),
                  expanded: Padding(padding: EdgeInsets.all(10),
                      child: Column(children: <Widget>[
                      leftAlignText(text: property.description,
                          leftPadding: size.getWidthPx(0),
                      textColor: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500),
                        SizedBox(height: size.getWidthPx(8)),
                        leftAlignText(text: 'Osoba odpowiedzialna: '+(property.responsible!=""?property.responsible:'-brak-'),
                            leftPadding: size.getWidthPx(0),
                            textColor: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500),
                      ])),
                ),
                SizedBox(height: size.getWidthPx(4)),
              ],
            )));
  }

}

Future<List<Photo>> fetchPhotos(http.Client client, int fault_id) async {
  var url = 'https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_photos&format=raw';
  var data = {'fault_id' : fault_id};

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
    return (photos.length>0) ? GridView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemBuilder: (context, index) {
        return propertyCard(context, photos[index]);
      },
    ) : Container();
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
                onTap: (){ launch('http://wkob.srv28629.microhost.com.pl/uploads/'+ property.src); },
                child: CachedNetworkImage(
                  imageUrl: 'http://wkob.srv28629.microhost.com.pl/uploads/thumbs/'+ property.src,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ))
        ),
            );
  }
}