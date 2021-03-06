import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:argon_flutter/constants/Theme.dart';

//widgets
import 'package:argon_flutter/widgets/navbar.dart';
import 'package:argon_flutter/widgets/card-horizontal.dart';
import 'package:argon_flutter/widgets/drawer.dart';
import 'package:argon_flutter/process/authorization.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:argon_flutter/model/test_post.dart';

RefreshController _refreshController;

var listData = [];
final Map<String, Map<String, String>> homeCards = {
  "Ice Cream": {
    "title": "Ice cream is made with carrageenan …",
    "image":
        "https://images.unsplash.com/photo-1516559828984-fb3b99548b21?ixlib=rb-1.2.1&auto=format&fit=crop&w=2100&q=80"
  },
  "Makeup": {
    "title": "Is makeup one of your daily esse …",
    "image":
        "https://images.unsplash.com/photo-1519368358672-25b03afee3bf?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2004&q=80"
  },
  "Coffee": {
    "title": "Coffee is more than just a drink: It’s …",
    "image":
        "https://images.unsplash.com/photo-1500522144261-ea64433bbe27?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2102&q=80"
  },
  "Fashion": {
    "title": "Fashion is a popular style, especially in …",
    "image":
        "https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1326&q=80"
  },
  "Argon": {
    "title": "Argon is a great free UI packag …",
    "image":
        "https://images.unsplash.com/photo-1482686115713-0fbcaced6e28?fit=crop&w=1947&q=80"
  }
};

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
  // final GlobalKey _scaffoldKey = new GlobalKey();

}

class _Home extends State<Home> {
  final TextEditingController searchbarController = new TextEditingController();
  var page = 0;
  @override
  void initState() {
    // init something.

    setState(() {
      _refreshController = RefreshController(initialRefresh: true);
    });
    super.initState();
  }

  // Future<void> _doAsyncStuff() async {
  //   var client = await createClient();
  //   var result = await client.read(Uri.parse('http://localhost:4200/user/me'));
  //   print(result);
  // }

  void _doProfileSearch(text) {
    try {
      _doProfile(text, page);
      _refreshController.requestRefresh();
    } catch (e) {
      print("Test");
    }
  }

  void _onRefresh() async {
    // monitor network fetch
    listData = [];
    page = 0;
    await _doProfile(searchbarController.text, 0);
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    page++;
    await _doProfile(searchbarController.text, page);
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  Future<void> _doProfile(text, page) async {
    try {
      print(text);
      var client = await createClient();
      TestPost test = TestPost(text, page);
      var result = await client.post(
          Uri.http('localhost:4200', '/user/test_post'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(test.toJson()));

      setState(() {
        print(result.body.toString());
        String jsonsDataString = result.body.toString();
        Map<String, dynamic> responseJson = jsonDecode(jsonsDataString);
        listData.addAll(responseJson['BODY']);
      });
      //_refreshController.requestRefresh();
    } catch (e) {
      print("Test");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Navbar(
          title: "Home",
          searchBar: true,
          rightOptions: false,
          isOnSearch: true,
          searchController: searchbarController,
          searchOnPressed: () {
            setState(() {
              _doProfileSearch(searchbarController.text);
            });
          },
        ),
        backgroundColor: ArgonColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: ArgonDrawer(currentPage: "Home"),
        body: Container(
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          child: SmartRefresher(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var item in listData)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CardHorizontal(
                          cta: item["name"],
                          title: item["lastname"],
                          img: homeCards["Ice Cream"]['image'],
                          tap: () {}),
                    ),
                  SizedBox(height: 8.0),
                ],
              ),
            ),
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
          ),
        ));
  }
}
