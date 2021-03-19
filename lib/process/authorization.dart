import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:convert';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:path_provider/path_provider.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:argon_flutter/process/service_locator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

final storage = new FlutterSecureStorage();
final authorizationEndpoint =
    Uri.parse('http://localhost:4200/oauth/authorise');
final redirectUrl = Uri.parse('http://localhost:4200/user/secure');
final tokenEndpoint = Uri.parse('http://localhost:4200/oauth/token');

Future<dynamic> passwordGrant(String username, password) async {
  Map data = {'username': username, 'password': password};
  var identifier = await storage.read(key: "clientIdentifier");
  var secret = await storage.read(key: "clientSecret");
  var result;
  var response =
      await http.post(Uri.http("localhost:4200", "login"), body: data);
  // This URL is an endpoint that's provided by the authorization server. It's
// usually included in the server's documentation of its OAuth2 API.

// The user should supply their own username and password.
  // final username = 'example user';
  // final password = 'example password';

// The authorization server may issue each client a separate client
// identifier and secret, which allows the server to tell which client
// is accessing it. Some servers may also have an anonymous
// identifier/secret pair that any client may use.
//
// Some servers don't require the client to authenticate itself, in which case
// these should be omitted.
  if (identifier == null) {
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    final errorCode = responseJson['HEAD']['error_code'];
    print(responseJson);
    if (errorCode == "0") {
      identifier = responseJson['BODY']['client_id'];
      secret = responseJson['BODY']['client_secret'];
      print(identifier);
      print(secret);
// Make a request to the authorization endpoint that will produce the fully
// authenticated Client.
      await storage.write(key: "clientIdentifier", value: identifier);
      await storage.write(key: "clientSecret", value: secret);
    }
  }
  try {
    // Once you have the client, you can use it just like any other HTTP client.
    var client = await oauth2.resourceOwnerPasswordGrant(
        tokenEndpoint, username, password,
        identifier: identifier, secret: secret);
    result = await client.read(Uri.parse('http://localhost:4200/user/secure'));
// Once we're done with the client, save the credentials file. This will allow
// us to re-use the credentials and avoid storing the username and password
// directly.
    Directory directory = await getApplicationDocumentsDirectory();
    File(directory.path + '/credentials.json')
        .writeAsString(client.credentials.toJson());
  } catch (e) {
    print(e);
    result = jsonEncode({'checkLogin': false});
  }

  return result;
}

Future<oauth2.Client> createClient() async {
  List<String> device = await getDeviceDetails();
  device.forEach((element) => print(element));
  Directory directory = await getApplicationDocumentsDirectory();
  final credentialsFile = File(directory.path + '/credentials.json');
  final identifier = await storage.read(key: "clientIdentifier");
  final secret = await storage.read(key: "clientSecret");
  // If the OAuth2 credentials have already been saved from a previous run, we
  // just want to reload them.
  var credentials =
      oauth2.Credentials.fromJson(await credentialsFile.readAsString());
  var client =
      oauth2.Client(credentials, identifier: identifier, secret: secret);
  try {
    var result =
        await client.read(Uri.parse('http://localhost:4200/user/secure'));
  } catch (e) {
    try {
      client = await refreshClient(client);
      print(credentialsFile.readAsString());
    } catch (e) {
      throw ("refresh expire");
    }
  }
  return client;
}

// Future<oauth2.Client> createClient() async {
//   Directory directory = await getApplicationDocumentsDirectory();
//   final credentialsFile = File(directory.path + '/credentials.json');
//   final identifier = await storage.read(key: "clientIdentifier");
//   final secret = await storage.read(key: "clientSecret");
//   var exists = await credentialsFile.exists();

//   // If the OAuth2 credentials have already been saved from a previous run, we
//   // just want to reload them.
//   if (exists) {
//     var credentials =
//         oauth2.Credentials.fromJson(await credentialsFile.readAsString());
//     return oauth2.Client(credentials, identifier: identifier, secret: secret);
//   }

//   // If we don't have OAuth2 credentials yet, we need to get the resource owner
//   // to authorize us. We're assuming here that we're a command-line application.
//   var grant = oauth2.AuthorizationCodeGrant(
//       identifier, authorizationEndpoint, tokenEndpoint,
//       secret: secret);

//   // A URL on the authorization server (authorizationEndpoint with some additional
//   // query parameters). Scopes and state can optionally be passed into this method.
//   var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);

//   // Redirect the resource owner to the authorization URL. Once the resource
//   // owner has authorized, they'll be redirected to `redirectUrl` with an
//   // authorization code. The `redirect` should cause the browser to redirect to
//   // another URL which should also have a listener.
//   //
//   // `redirect` and `listen` are not shown implemented here.
//   await redirect(authorizationUrl);
//   var responseUrl = await listen(redirectUrl);
//   // Once the user is redirected to `redirectUrl`, pass the query parameters to
//   // the AuthorizationCodeGrant. It will validate them and extract the
//   // authorization code to create a new Client.
//   return await grant.handleAuthorizationResponse(responseUrl.queryParameters);
// }

Future<oauth2.Client> refreshClient(client) async {
  Directory directory = await getApplicationDocumentsDirectory();
  final identifier = await storage.read(key: "clientIdentifier");
  final secret = await storage.read(key: "clientSecret");
  var credentials;
  // If the OAuth2 credentials have already been saved from a previous run, we
  // just want to reload them.
  try {
    credentials = await client.credentials
        .refresh(identifier: identifier, secret: secret, basicAuth: true);
    client = oauth2.Client(credentials, identifier: identifier, secret: secret);
    File(directory.path + '/credentials.json')
        .writeAsString(client.credentials.toJson());
    return client;
  } on FormatException catch (e) {
    locator<NavigationService>().navigateTo('Login');
    Get.defaultDialog(title: "Session", content: Text("หมดอายุ"));
    throw ("Token Expire");
  } catch (e) {
    Get.defaultDialog(title: "Disconnect", content: Text("Disconnect"));
    throw ("Disconnect");
  }
}

Future<List<String>> getDeviceDetails() async {
  String deviceName;
  String deviceVersion;
  String identifier;
  final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      deviceName = build.model;
      deviceVersion = build.version.toString();
      identifier = build.androidId; //UUID for Android
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      deviceName = data.name;
      deviceVersion = data.systemVersion;
      identifier = data.identifierForVendor; //UUID for iOS
    }
  } on PlatformException {
    print('Failed to get platform version');
  }

//if (!mounted) return;
  return [deviceName, deviceVersion, identifier];
}

Future<void> redirect(Uri url) async {
  // Client implementation detail
}

Future<Uri> listen(Uri url) async {
  // Client implementation detail
  return Uri();
}
