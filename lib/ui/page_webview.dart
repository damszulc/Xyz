import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_collections/ui/page_attachments.dart';
import 'package:flutter_ui_collections/ui/page_home.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';

import 'package:flutter_ui_collections/utils/utils.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui_collections/utils/utils.dart';
import 'package:flutter_ui_collections/widgets/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../LocalBindings.dart';
import 'page_single.dart';

class PageWebview extends StatefulWidget {
  @override
  final String address;
  const PageWebview (this.address);
  _PageWebviewState createState() => _PageWebviewState();
}

class _PageWebviewState extends State<PageWebview> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final webview = FlutterWebviewPlugin();
  StreamSubscription<String> _onWebViewUrlChanged;


  @override
  void dispose() {
    webview.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _onWebViewUrlChanged = webview.onUrlChanged.listen((String url) {
      if (url.contains('.pdf') || url.contains('.jpg') || url.contains('.png') || url.contains('.jpeg') || url.contains('.doc') || url.contains('.docx') || url.contains('.zip')) {
        webview.stopLoading();
        webview.hide();
        webview.reloadUrl(widget.address);
        webview.show();
        launchURL(url);
      }
    });


  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
          url: widget.address,
      withJavascript: true,
      withLocalStorage: true,
      withZoom: true,
      appCacheEnabled: true,
      clearCookies: true,
      clearCache: true,
      allowFileURLs: true,
      geolocationEnabled: true,
      initialChild: Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            'proszę czekać ......',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
          appBar: new AppBar(
            title: new Text(""),
            backgroundColor: colorCurve,
            actions: <Widget>[
              IconButton(
                padding: EdgeInsets.all(0.0),
                icon: Image.asset('assets/EKOB-1.png'),
                iconSize: 80,
                alignment: Alignment(-1.0, -1.0),

              )],
              automaticallyImplyLeading: false,
              leading: new Container(child: BackButton(
                color: Colors.white, onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage())
                );
              },
              ))
          ),
        );
  }

}