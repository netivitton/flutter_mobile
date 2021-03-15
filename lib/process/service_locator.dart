import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

// จะได้ Instance ของ GetIt มาซึ่งมีเพียงตัวเดียวในโปรแกรม เรียกที่ไหนก็ได้ตัวเดียวกัน
GetIt locator = GetIt.instance;

// ฟังก์ชันเริ่มต้นในการกำหนดว่าจะสร้าง Singleton หรือ อะไรบ้าง
void setupLocator() {
  // สร้าง Singleton ของ class NavigationService
  locator.registerLazySingleton(() => NavigationService());
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }
}
