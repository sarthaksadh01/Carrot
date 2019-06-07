import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_apps/device_apps.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScreenRecord extends StatefulWidget {
  final String channelName, category, title, username, img;
  final List<String> hashtags;
  const ScreenRecord(
      {Key key,
      this.channelName,
      this.category,
      this.hashtags,
      this.title,
      this.username,
      this.img})
      : super(key: key);

  @override
  _ScreenRecordState createState() => _ScreenRecordState();
}

class _ScreenRecordState extends State<ScreenRecord> {
  bool _started = false;
  String _msgUid = "";
  @override
  void initState() {
    super.initState();
    // _start();
  }

  @override
  void dispose() {
    _stopScreenShare();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Please select an app to continue"),
        ),
        body: _started == false
            ? FutureBuilder(
                future: DeviceApps.getInstalledApplications(
                    includeAppIcons: true,
                    includeSystemApps: true,
                    onlyAppsWithLaunchIntent: true),
                builder: (context, data) {
                  if (data.data == null) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    List<Application> apps = data.data;
                    print(apps);
                    return ListView.builder(
                        itemBuilder: (context, position) {
                          Application app = apps[position];
                          return Column(
                            children: <Widget>[
                              ListTile(
                                leading: app is ApplicationWithIcon
                                    ? CircleAvatar(
                                        backgroundImage: MemoryImage(app.icon),
                                        backgroundColor: Colors.white,
                                      )
                                    : null,
                                onTap: () {
                                  _startScreenShare(app.appName);
                                },
                                title: Text("${app.appName}"),
                              ),
                              Divider(
                                height: 1.0,
                              )
                            ],
                          );
                        },
                        itemCount: apps.length);
                  }
                })
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("You are live!"),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  MaterialButton(
                    height: 45,
                    color: Color(0xfffd6a02),
                    child: Text(
                      "Stop Recording",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _stopScreenShare();
                    },
                  ),
                ],
              )));
  }

  Future<void> _startScreenShare(String appName) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    const platform = const MethodChannel('samples.flutter.io/screen_record');
    try {
      final String result =
          await platform.invokeMethod('startScreenShare', {"uid": user.uid});
      if (result == "started") {
        _updateDatabase(appName);
      }
    } on PlatformException catch (e) {}
  }

  Future<void> _stopScreenShare() async {
    const platform = const MethodChannel('samples.flutter.io/screen_record');
    try {
      final String result = await platform.invokeMethod('stopScreenShare');
      if (result == "stopped") {
        setState(() {
          _started = false;
        });
        _leaveChanel();
      }
    } on PlatformException catch (e) {}

    setState(() {
      // _batteryLevel = batteryLevel;
    });
  }

  _updateDatabase(String appName) {
    print(widget.title);
    _msgUid = widget.channelName + randomString(10);
    Firestore.instance.collection('Live').add({
      'category': widget.category,
      'uid': widget.channelName,
      'username': widget.username,
      'msg_uid': _msgUid,
      'hashtags': widget.hashtags,
      'viewers': [],
      'likes': [],
      'comments': [],
      'time': new DateTime.now().millisecondsSinceEpoch,
      'status': 'online',
      'title': widget.title,
      'img': widget.img,
      'start_time': DateTime.now().millisecondsSinceEpoch,
      'end_time': DateTime.now().millisecondsSinceEpoch
    }).then((doc) {
      setState(() {
        _started = true;
      });
//  _openApp(appName);
    }).catchError((e) {});
  }

  _leaveChanel() {
    Firestore.instance
        .collection('Live')
        .where('msg_uid', isEqualTo: _msgUid)
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((doc) {
        Firestore.instance
            .collection('Live')
            .document(doc.documentID)
            .updateData({'status': 'offline'}).then((onValue) {
          print('done');
        });
      });
    });
  }

  _openApp(String appName) async {
    const platform = const MethodChannel('samples.flutter.io/screen_record');
    try {
      final String result =
          await platform.invokeMethod('openApp', {"packageName": appName});
    } on PlatformException catch (e) {}
  }
}
