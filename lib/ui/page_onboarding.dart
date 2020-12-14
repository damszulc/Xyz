import 'package:flutter/material.dart';
import 'package:flutter_ui_collections/ui/page_objects.dart';
import 'package:flutter_ui_collections/ui/page_login.dart';
import 'package:flutter_ui_collections/utils/Constants.dart';
import 'package:flutter_ui_collections/widgets/dots_indicator.dart';
import 'package:flutter_ui_collections/utils/utils.dart';
import '../LocalBindings.dart';
import 'intro_page.dart';
import 'page_objects.dart';
import "../main.dart";

class OnBoardingPage extends StatefulWidget {
  OnBoardingPage({Key key}) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final _controller = PageController();
  bool leadingVisibility = false;
  Screen  size;
  
  final List<Widget> _pages = [
    IntroPage("assets/start1.png","Bezpieczeństwo", "Wszystkie dane przechowywane są zgodnie z RODO."),
    IntroPage("assets/start2.png","Prostota", "W kilku ruchach dodasz zdjęcia, sprawdzisz kontrole, zweryfikujesz informacje o obiektach."),
    IntroPage("assets/start3.png","Szybkość", "Nigdy nie stracisz już więcej czasu na skanowanie, drukowanie, a dane natychmiast są dostępne dla Twoich pracowników i innych użytkowników z uprawnieniami."),
  ];
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    bool isLastPage = currentPageIndex == _pages.length - 1;
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: <Widget>[
              pageViewFillWidget(),
              appBarWithButton(isLastPage, context),
              bottomDotsWidget()
            ],
          ),
        ));
  }

  Positioned bottomDotsWidget() {
    return Positioned(
        bottom: size.getWidthPx(20),
        left: 0.0,
        right: 0.0,
        child: DotsIndicator(
          controller: _controller,
          itemCount: _pages.length,
          color: colorCurve,
          onPageSelected: (int page) {
            _controller.animateToPage(
              page,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
        ));
  }

  Positioned appBarWithButton(bool isLastPage, BuildContext context) {
    return Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      child: new SafeArea(
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          primary: false,
          centerTitle: true,
          leading: Visibility(
              visible: leadingVisibility,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _controller.animateToPage(currentPageIndex - 1,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                },
              )),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: displayWidth(context) * 0.01, right:  displayWidth(context) * 0.035, bottom: displayWidth(context) * 0.035),
              child: RaisedButton(
                child: Text(
                  isLastPage ? 'STARTUJEMY' : 'DALEJ',
                  style: TextStyle(fontFamily: 'Exo2',fontWeight: FontWeight.w500,fontSize: 14,color: Colors.grey.shade700),
                ),
                onPressed: isLastPage
                    ? () async{
                  // Last Page Done Click
                  LocalStorage.sharedInstance.writeValue(key:Constants.isOnBoard,value: "1");

                  String user_id = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
                  if(user_id != null) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => ObjectsPage()));
                  }
                  else {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  }
                }
                    : () {
                  _controller.animateToPage(currentPageIndex + 1,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn);
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Positioned pageViewFillWidget() {
    return Positioned.fill(
        child: PageView.builder(
          controller: _controller,
          itemCount: _pages.length,
          itemBuilder: (BuildContext context, int index) {
            return _pages[index % _pages.length];
          },
          onPageChanged: (int p) {
            setState(() {
              currentPageIndex = p;
              if (currentPageIndex == 0) {
                leadingVisibility = false;
              } else {
                leadingVisibility = true;
              }
            });
          },
        ));
  }
}