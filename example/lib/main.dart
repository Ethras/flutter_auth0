import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_auth0/auth0.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final audienceInputController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
            child: Column(
          children: <Widget>[
            new TextField(controller: audienceInputController),
            new RaisedButton(
              child: new Text(
                "Log in",
                style: new TextStyle(fontSize: 18.0),
              ),
              onPressed: () {
                Auth0.login(audienceInputController.text);
              },
              color: Colors.blue,
              textColor: Colors.white,
            ),
            new RaisedButton(
              child: new Text(
                "Log out",
                style: new TextStyle(fontSize: 18.0),
              ),
              onPressed: () {
                Auth0.logout();
              },
              color: Colors.blue,
              textColor: Colors.white,
            ),
            RaisedButton(
              onPressed: getProfile,
              child: Text("Get profile"),
            ),
            RaisedButton(
              child: Text(
                "Get access token",
                style: TextStyle(fontSize: 18.0),
              ),
              onPressed: () async {
                print(await Auth0.accessToken);
              },
              color: Colors.blue,
              textColor: Colors.white,
            ),
          ],
        )),
      ),
    );
  }

  void getProfile() async {
    final profile =
        await Auth0.getUserInfo();
    print(profile);
  }
}
