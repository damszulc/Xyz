import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';
import 'package:flutter_ui_collections/ui/page_view.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_ui_collections/utils/utils.dart';

import '../LocalBindings.dart';
import 'page_view.dart';

Future<List<Photo>> fetchPhotos(http.Client client) async {
  String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
  var url = 'https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_objects&format=raw';
  var data = {'user_id': user_id};

  // Starting Web API Call.
  final response = await http.post(url, body: json.encode(data));
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parsePhotos, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Photo> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class Photo {
  final int id;
  final String name;
  final String type;
  final String location;
  final String image;
  final int index;

  Photo({this.id, this.name, this.type, this.location, this.image, this.index});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: int.parse(json['id']) as int,
      name: json['name'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      image: json['image'] as String,
      index: int.parse(json['index']) as int
    );
  }
}

class ObjectsPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<ObjectsPage> {

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
        title: Text("Moje obiekty",
            style:
            TextStyle(fontFamily: "Exo2", color: backgroundColor)),
          actions: <Widget>[
      IconButton(
      padding: EdgeInsets.all(0.0),
      icon: Image.asset('assets/EKOB-1.png'),
      iconSize: 80,
      alignment: Alignment(-1.0, -1.0),

    )],
        backgroundColor: colorCurve
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? PhotosList(photos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future navigate () async {
    String isLoggedIn = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
    if(isLoggedIn == null || isLoggedIn == "0"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return propertyCard(context, photos[index]);

        //return ;
        return Image.network(photos[index].image);
      },
    );
  }

  Center appLogo = new Center(
      child: Image(
          image: new NetworkImage("https://wkob.pl/images/logo.png"),
          alignment: FractionalOffset.center));

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

  InkWell propertyCard(BuildContext context, Photo property) {
    return InkWell(
        onTap: (){ Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageViewDemo(property.index)),
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
                ClipRRect(
                    child: Image.network('${property.image}', height: size.getWidthPx(60),)),
                SizedBox(height: size.getWidthPx(8)),
                leftAlignText(
                    text: property.name,
                    leftPadding: size.getWidthPx(8),
                    textColor: colorCurve,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w800),
                SizedBox(height: size.getWidthPx(4)),
                leftAlignText(
                    text: property.location,
                    leftPadding: size.getWidthPx(8),
                    textColor: Colors.black54,
                    fontSize: 12.0),
                leftAlignText(
                    text: property.type,
                    leftPadding: size.getWidthPx(8),
                    textColor: Colors.black54,
                    fontSize: 12.0),
              ],
            ))));
  }
}

