import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';
import 'package:flutter_ui_collections/ui/page_webview.dart';
import 'package:flutter_ui_collections/utils/utils.dart';
import 'package:flutter_ui_collections/widgets/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../LocalBindings.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isLocalNotification = true;
  bool isPushNotification = true;
  bool isLocalCalendar = true;
  bool isPushCalendar = true;
  bool isPrivateAccount = true;
  String userName;
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    // TODO: implement initState

    navigate();
    super.initState();
    this._getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Ustawienia",
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
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarColor: backgroundColor),
        child: Container(
          color: backgroundColor,
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('wersja: 1.4.13', textAlign: TextAlign.center,)),
                accountSection(),
                pushNotificationSection(),
                pushCalendarSection(),
                getHelpSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SettingSection getHelpSection() {
    return SettingSection(
      headerText: "\nPomoc".toUpperCase(),
      headerFontSize: 15.0,
      headerTextColor: Colors.black87,
      backgroundColor: Colors.white,
      disableDivider: false,
      children: <Widget>[
        Container(
          child: TileRow(
            label: "Kontakt",
            disableDivider: false,
              onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PageWebview('https://wkob.pl/index.php/kontakt?tmpl=component')))
          ),
        ),
        Container(
          child: TileRow(
            label: "Regulamin",
            disableDivider: false,
            onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PageWebview('https://wkob.pl/index.php/regulamin?tmpl=component')))
                          ,
          ),
        ),
        Container(
          child: TileRow(
            label: "Wyloguj",
            disableDivider: false,
            onTap: () async {
              void set = LocalStorage.sharedInstance.writeValue(key:Constants.isLoggedIn, value: "0");
              // Navigate to Profile Screen & Sending Email to Next Screen.
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage())
              );
            },
          ),
        )
      ],
    );
  }

  SettingSection accountSection() {
    return SettingSection(
      headerText: "\nKonto".toUpperCase(),
      headerFontSize: 15.0,
      headerTextColor: Colors.black87,
      backgroundColor: Colors.white,
      disableDivider: false,
      children: <Widget>[
        Container(
          child: TileRow(
            label: "Użytkownik",
            disabled: true,
            rowValue: userName,
            disableDivider: false,
            onTap: () {},
          ),
        ),

      ],
    );
  }

  SettingSection pushNotificationSection() {
    return SettingSection(
      headerText: "\nPowiadomienia".toUpperCase(),
      headerFontSize: 15.0,
      headerTextColor: Colors.black87,
      backgroundColor: Colors.white,
      disableDivider: false,
      children: <Widget>[
        Container(
          child: SwitchRow(
            label: "Kontrole",
            disableDivider: false,
            value: isPushNotification,
            onSwitchChange: (switchStatus) {
              setState(() {
                switchStatus
                    ? isPushNotification = true
                    : isPushNotification = false;
                _setSettings('controls_not', switchStatus);
              });
            },
            onTap: () {},
          ),
        ),
        Container(
          child: SwitchRow(
            label: "Usterki",
            disableDivider: false,
            value: isLocalNotification,
            onSwitchChange: (switchStatus) {
              setState(() {
                switchStatus
                    ? isLocalNotification = true
                    : isLocalNotification = false;
                _setSettings('faults_not', switchStatus);
              });
            },
            onTap: () {},
          ),
        )
      ],
    );
  }

  SettingSection pushCalendarSection() {
    return SettingSection(
      headerText: "\nTerminarz".toUpperCase(),
      headerFontSize: 15.0,
      headerTextColor: Colors.black87,
      backgroundColor: Colors.white,
      disableDivider: false,
      children: <Widget>[
        Container(
          child: SwitchRow(
            label: "Kontrole",
            disableDivider: false,
            value: isPushCalendar,
            onSwitchChange: (switchStatus) {
              setState(() {
                switchStatus
                    ? isPushCalendar = true
                    : isPushCalendar = false;
                _setSettings('controls_cal', switchStatus);
              });
            },
            onTap: () {},
          ),
        ),
        Container(
          child: SwitchRow(
            label: "Usterki",
            disableDivider: false,
            value: isLocalCalendar,
            onSwitchChange: (switchStatus) {
              setState(() {
                switchStatus
                    ? isLocalCalendar = true
                    : isLocalCalendar = false;
                _setSettings('faults_cal', switchStatus);
              });
            },
            onTap: () {},
          ),
        )
      ],
    );
  }

  _getUserData() async {
    String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
    http.post(
        "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_user_data&format=raw",
        body: {
          "user_id": user_id
        }).then((result) {
        var res_dec = json.decode(result.body);
        print(res_dec);
        userName = res_dec['name'];
        isLocalNotification = toBoolean(res_dec['faults_not']);
        isPushNotification = toBoolean(res_dec['controls_not']);
        isLocalCalendar = toBoolean(res_dec['faults_cal']);
        isPushCalendar = toBoolean(res_dec['controls_cal']);
        setState(() {

        });
    });
  }

  bool toBoolean(String str, [bool strict]) {
    if (strict == true) {
      return str == '1' || str == 'true';
    }
    return str != '0' && str != 'false' && str != '';
  }

  _setSettings(name, value) async {
    String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
    http.post(
        "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=set_settings&format=raw",
        body: {
          "user_id": user_id,
          "name": name.toString(),
          "value": value.toString()
        }).then((result) {
            print(result.body);
          });
  }

  Future navigate () async {
    String isLoggedIn = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
    if(isLoggedIn == null || isLoggedIn == "0"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
