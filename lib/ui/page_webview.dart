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
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
          url: widget.address,
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
          ),
        );
  }

}