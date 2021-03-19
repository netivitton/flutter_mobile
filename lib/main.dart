import 'package:flutter/material.dart';

// screens
import 'package:argon_flutter/screens/login.dart';
import 'package:argon_flutter/screens/home.dart';
import 'package:argon_flutter/screens/profile.dart';
import 'package:argon_flutter/screens/register.dart';
import 'package:argon_flutter/screens/articles.dart';
import 'package:argon_flutter/screens/elements.dart';
import 'package:argon_flutter/process/service_locator.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
        footerTriggerDistance: 15,
        dragSpeedRatio: 0.91,
        headerBuilder: () => MaterialClassicHeader(),
        footerBuilder: () => ClassicFooter(),
        enableLoadingWhenNoData: false,
        enableRefreshVibrate: false,
        enableLoadMoreVibrate: false,
        shouldFooterFollowWhenNotFull: (state) {
          // If you want load more with noMoreData state ,may be you should return false
          return false;
        },
        child: GetMaterialApp(
          title: 'Argon PRO Flutter',
          theme: ThemeData(fontFamily: 'OpenSans'),
          initialRoute: "/login",
          debugShowCheckedModeBanner: false,
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
        ));
  }
}
