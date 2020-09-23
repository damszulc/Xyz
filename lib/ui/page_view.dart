import 'dart:convert';
import 'package:flutter_ui_collections/ui/page_single.dart';
import 'package:flutter_ui_collections/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'dart:async';

import '../LocalBindings.dart';

class PageViewDemo extends StatefulWidget {
  @override

  final int index;
  const PageViewDemo (this.index);
  _PageViewDemoState createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<PageViewDemo> {

  final String url = "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_objects&format=raw";
  List data = List(); //edited line
  List pages = List();
  PageController _controller;

  @override
  void initState() {
    getProtocols();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> getProtocols() async {
    // Starting Web API Call.

    String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
    final response = await http.post(url, body: json.encode( {'user_id': user_id}));
    var resBody = json.decode(response.body);

    setState(() {
      data = resBody;
      pages = data.map((item) {
        return PageSingle(int.parse(item['id']), 0);}
      ).toList();
      _controller = PageController(
          initialPage: widget.index,
          keepPage: false
      );
    });

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: pages
    );
  }
}