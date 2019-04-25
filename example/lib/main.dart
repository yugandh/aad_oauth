import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'AAD OAuth Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'AAD OAuth Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final Config config = new Config("YOUR_TENANT_ID", "YOUR CLIENT ID", "openid profile offline_access");
  final AadOAuth oauth = AadOAuth(config);

  static const userProfileBaseUrl = 'https://graph.microsoft.com/v1.0/me';
  static const authorization = 'Authorization';
  static const bearer = 'Bearer ';

  Widget build(BuildContext context) {
    // adjust window size for browser login
    oauth.setWebViewScreenSize(MediaQuery.of(context).size);

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              "AzureAD OAuth",
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Logout'),
            onTap: () {
              logout();
            },
          ),
        ],
      ),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
      new FlatButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login() async {
    try {
      await oauth.login();
      String accessToken = await oauth.getAccessToken();
      print(accessToken);
      showMessage("Logged in successfully, your access token: $accessToken");
    } catch (e) {
      showError(e);
    }

    authenticateMyProfile();
  }

  void logout() async {
    await oauth.logout();
    showMessage("Logged out");
  }

  // Microsoft Graph API call to fetch user profile
  Future<void> authenticateMyProfile() async {
    try {
      await oauth.login();
      String accessToken = await oauth.getAccessToken();
      print(accessToken);
      var response = await http.get(userProfileBaseUrl, headers: {authorization: bearer + accessToken});
      print(response.body);
      if(response.statusCode == 200) {
        print("Request success with status: ${response.statusCode}.");
      } else {
        print("Request failed with status: ${response.statusCode}.");
      }
    } catch (e) {
      print('login error');
    }
  }
}
