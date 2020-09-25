import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui_collections/ui/page_webview.dart';
import 'package:flutter_ui_collections/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_ui_collections/utils/utils.dart';
import 'package:flutter_ui_collections/widgets/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../LocalBindings.dart';
import 'page_home.dart';
import 'page_signup.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  FocusNode _emailFocusNode = new FocusNode();
  FocusNode _passFocusNode = new FocusNode();
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future userLogin() async{

    bool visible = false ;
    // Showing CircularProgressIndicator.
    setState(() {
      visible = true ;
    });

    // Getting value from Controller
    String email = _emailController.text;
    String password = _passwordController.text;

    // SERVER LOGIN API URL
    var url = 'https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=login&format=raw';

    // Store all data with Param Name.
    var data = {'login': email, 'password' : password};

    // Starting Web API Call.
    var response = await http.post(url, body: json.encode(data));

    // Getting Server response into variable.
    var message = jsonDecode(response.body);

    // If the Response Message is Matched.
    if(message != null)
    {

      // Hiding the CircularProgressIndicator.
      setState(() {
        visible = false;
      });

      String user_id = message.toString();
      LocalStorage.sharedInstance.writeValue(key:Constants.isLoggedIn, value: user_id);

      http.post(
          "https://wkob.pl/index.php?option=com_ajax&plugin=mobileapp&action=get_group&format=raw",
          body: {
            "user_id": user_id
          }).then((result) {
        var user_group = json.decode(result.body).toString();
        LocalStorage.sharedInstance.writeValue(key:Constants.userGroup, value: user_group);
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage())
        );
      });

      // Navigate to Profile Screen & Sending Email to Next Screen.

    }else{

      // If Email or Password did not Matched.
      // Hiding the CircularProgressIndicator.
      setState(() {
        visible = false;
      });

      // Showing Alert Dialog with Response JSON Message.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Błędny login i/lub hasło!"),
            actions: <Widget>[
              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

  }

  Screen size;

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
          title: Text("Logowanie",
              style:
              TextStyle(fontFamily: "Exo2", color: backgroundColor)),
          backgroundColor: colorCurve,
        ),
        body: AnnotatedRegion(
          value: SystemUiOverlayStyle(
              statusBarColor: backgroundColor,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarIconBrightness: Brightness.light,
              systemNavigationBarColor: backgroundColor),

          child: Container(
            color: Colors.white,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[



                    SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: size.getWidthPx(20),
                        vertical: size.getWidthPx(20)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            appLogo,
                   //       _loginGradientText(),
                          SizedBox(height: size.getWidthPx(30)),
                          loginFields()
                        ]),
                  ),
                )
              ]),
            ),
          ),
        ));
  }

  Center appLogo = new Center(
    child: Image(
      image: new NetworkImage("https://wkob.pl/images/logo.png"),
      alignment: FractionalOffset.center));

  RichText _textAccount() {
    return RichText(
      text: TextSpan(
          text: "Don't have an account? ",
          children: [
            TextSpan(
              style: TextStyle(color: Colors.deepOrange),
              text: 'Create your account.',
              recognizer: TapGestureRecognizer()
                ..onTap = () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage())),
            )
          ],
          style: TextStyle(color: Colors.black87, fontSize: 14, fontFamily: 'Exo2')),
    );
  }

  Center _loginGradientText() {
    return Center(
        child: GradientText(
            'Logowanie',
            gradient: LinearGradient(colors: [
              Color.fromRGBO(1, 173, 175, 1.0),
              Color.fromRGBO(45, 160, 240, 1.0)
            ]),
            style: TextStyle(fontFamily: 'Exo2',fontSize: 36, fontWeight: FontWeight.bold)
        )
    );
  }

  BoxField _emailWidget() {
    return BoxField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        hintText: "Wpisz login",
        lableText: "Login",
        obscureText: false,
        onSaved: (String val) {
          _email = val;
        },
        onFieldSubmitted: (String value) {
          FocusScope.of(context).requestFocus(_passFocusNode);
        },
        icon: Icons.email,
        iconColor: colorCurve);
  }

  BoxField _passwordWidget() {
    return BoxField(
        controller: _passwordController,
        focusNode: _passFocusNode,
        hintText: "Wpisz hasło",
        lableText: "Hasło",
        obscureText: true,
        icon: Icons.lock_outline,
        onSaved: (String val) {
          _password = val;
        },
        iconColor: colorCurve);
  }

  Container _loginButtonWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: size.getWidthPx(20), horizontal: size.getWidthPx(16)),
      width: size.getWidthPx(180),
      child: RaisedButton(
        highlightColor: Colors.yellow,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        padding: EdgeInsets.all(size.getWidthPx(8)),
        child: Text(
          "Zaloguj się",
          style: TextStyle(fontFamily: 'Exo2',color: Colors.white, fontSize: 18.0),
        ),
        color: colorCurve,
        onPressed: () {
          // Going to DashBoard
          userLogin();
        },
      ),
    );
  }

  GestureDetector socialCircleAvatar(String assetIcon,VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(

        maxRadius: size.getWidthPx(24),
        backgroundColor: Colors.transparent,
        child: Image.asset(assetIcon),
      ),
    );
  }


  loginFields() =>
      Container(
        child: Form(
            key: _formKey,
            child: Column(

              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _emailWidget(),
                SizedBox(height: size.getWidthPx(8)),
                _passwordWidget(),
                GestureDetector(
                    onTap: ()  => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PageWebview('https://wkob.pl/index.php/component/users/?view=reset&Itemid=539&tmpl=component'))),
                    child: Padding(
                      padding: EdgeInsets.only(right: size.getWidthPx(24)),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Text("Zapomniałeś hasła?",
                              style: TextStyle(fontFamily: 'Exo2',fontSize: 16.0))),
                    )),
                SizedBox(height: size.getWidthPx(8)),
                _loginButtonWidget(),
                SizedBox(height: size.getWidthPx(28)),
                Center(
                          child: Text("Nie masz jeszcze konta?",
                              style: TextStyle(fontFamily: 'Exo2',fontSize: 20.0)),
                    ),
                SizedBox(height: size.getWidthPx(10)),
                Container(
                width: size.getWidthPx(150),
                child: RaisedButton(
                  highlightColor: Colors.yellow,
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  padding: EdgeInsets.all(size.getWidthPx(8)),
                  child: Text(
                    "Zarejestruj się",
                    style: TextStyle(fontFamily: 'Exo2',color: Colors.white, fontSize: 18.0),
                  ),
                  color: colorCurveSecondary,
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PageWebview('https://wkob.pl/index.php/component/users/?view=registration&Itemid=539&tmpl=component'))),
                )),

              ],
            )),
      );
}


