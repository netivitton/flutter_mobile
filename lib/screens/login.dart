import 'dart:ui';
import 'dart:convert';
import 'package:argon_flutter/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:argon_flutter/constants/Theme.dart';
import 'package:argon_flutter/widgets/input.dart';
import 'package:http/http.dart' as http;
import 'package:argon_flutter/process/authorization.dart';
import 'package:argon_flutter/process/service_locator.dart';

class Login extends StatelessWidget {
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    login(String username, password) async {
      var result = await passwordGrant(username, password);
      Map<String, dynamic> passwordGrantResult = jsonDecode(result);
      if (passwordGrantResult['checkLogin']) {
        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(builder: (BuildContext context) => Home()),
        //     (Route<dynamic> route) => false);
        locator<NavigationService>().navigateTo('home');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => new CupertinoAlertDialog(
            title: new Text("สถานะ"),
            content: new Text("รหัสผ่านไม่ถูกต้อง"),
            actions: [
              CupertinoButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        );
      }
    }

    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/img/onboard-background.png"),
                  fit: BoxFit.cover))),
      Padding(
        padding: const EdgeInsets.only(top: 85, left: 32, right: 32, bottom: 5),
        child: Container(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset("assets/img/argon-logo-onboarding.png", scale: 1),
                  Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50, bottom: 50.0),
                          child: Text("ระบบสุดโหด",
                              style: TextStyle(
                                  color: ArgonColors.white,
                                  fontSize: 50.0,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 0.0),
                          child: Input(
                            controller: usernameController,
                            placeholder: "Phone Number",
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0, right: 0.0),
                          child: Input(
                            controller: passwordController,
                            placeholder: "Password",
                            prefixIcon: Icon(Icons.lock),
                            obscureText: true,
                          ),
                        ),
                      ),
                      Container(
                        child: SafeArea(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, //Center Column contents vertically,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 40.0),
                                child: SizedBox(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: ArgonColors.primary,
                                      textStyle: TextStyle(
                                        color: ArgonColors.text,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      login(usernameController.text,
                                          passwordController.text);
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                            top: 12,
                                            bottom: 12),
                                        child: Text("เข้าสู่ระบบ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0))),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 40.0, left: 30.0),
                                child: SizedBox(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: ArgonColors.secondary,
                                      textStyle: TextStyle(
                                        color: ArgonColors.text,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, '/home');
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                            top: 12,
                                            bottom: 12),
                                        child: Text("ลืมรหัสผ่าน",
                                            style: TextStyle(
                                                color: ArgonColors.text,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    ]));
  }
}
