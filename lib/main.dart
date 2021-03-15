import 'package:flutter/material.dart';

// screens
import 'package:argon_flutter/screens/login.dart';
import 'package:argon_flutter/screens/home.dart';
import 'package:argon_flutter/screens/profile.dart';
import 'package:argon_flutter/screens/register.dart';
import 'package:argon_flutter/screens/articles.dart';
import 'package:argon_flutter/screens/elements.dart';
import 'package:argon_flutter/process/service_locator.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argon PRO Flutter',
      theme: ThemeData(fontFamily: 'OpenSans'),
      initialRoute: "/login",
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        "/login": (BuildContext context) => new Login(),
        "/home": (BuildContext context) => new Home(),
        "/profile": (BuildContext context) => new Profile(),
        "/articles": (BuildContext context) => new Articles(),
        "/elements": (BuildContext context) => new Elements(),
        "/account": (BuildContext context) => new Register(),
      },
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'profile':
            return MaterialPageRoute(builder: (context) => Profile());
          case 'articles':
            return MaterialPageRoute(builder: (context) => Articles());
          case 'elements':
            return MaterialPageRoute(builder: (context) => Elements());
          case 'account':
            return MaterialPageRoute(builder: (context) => Register());
          case 'home':
            return MaterialPageRoute(builder: (context) => Home());
          case 'login':
          default:
            return MaterialPageRoute(builder: (context) => Login());
        }
      },
    );
  }
}
