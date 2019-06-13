import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_apps/device_apps.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ScreenRecord extends StatefulWidget {
  final String channelName, category, title, username, img;
  final List<String> hashtags;
  final int level;
  const ScreenRecord(
      {Key key,
      this.channelName,
      this.category,
      this.hashtags,
      this.title,
      this.username,
      this.img,
      this.level})
      : super(key: key);

  @override
  _ScreenRecordState createState() => _ScreenRecordState();
}

class _ScreenRecordState extends State<ScreenRecord> {
  bool _started = false;
  String _msgUid = "";
  @override
  void initState() {
    _startScreenShare("");
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
          title: Text("Go live!"),
        ),
        body: _started == false
            ? FlareActor(
                "assets/flare/loading.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: "Untitled",
              )
            // ? FutureBuilder(
            //     future: DeviceApps.getInstalledApplications(
            //         includeAppIcons: true,
            //         includeSystemApps: true,
            //         onlyAppsWithLaunchIntent: true),
            //     builder: (context, data) {
            //       if (data.data == null) {
            //         return Center(child: CircularProgressIndicator());
            //       } else {
            //         List<Application> apps = data.data;
            //         print(apps);
            //         return ListView.builder(
            //             itemBuilder: (context, position) {
            //               Application app = apps[position];
            //               return Column(
            //                 children: <Widget>[
            //                   ListTile(
            //                     leading: app is ApplicationWithIcon
            //                         ? CircleAvatar(
            //                             backgroundImage: MemoryImage(app.icon),
            //                             backgroundColor: Colors.white,
            //                           )
            //                         : null,
            //                     onTap: () {
            //                       _startScreenShare(app.appName);
            //                     },
            //                     title: Text("${app.appName}"),
            //                   ),
            //                   Divider(
            //                     height: 1.0,
            //                   )
            //                 ],
            //               );
            //             },
            //             itemCount: apps.length);
            //       }
            //     })
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
                      "Stop Screen Sharing!",
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
       Navigator.pushReplacementNamed(context, '/Home');
      }
    } on PlatformException catch (e) {}

   
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
      'status': 'online',
      'title': widget.title,
      'img': widget.img,
      'start_time': DateTime.now().millisecondsSinceEpoch,
      'level':widget.level,
       'type':"ScreenRecord"
    }).then((doc) {
      _sendNotification();
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

  _sendNotification()async{
     var result = await http.post(
        "http://ec2-13-235-73-103.ap-south-1.compute.amazonaws.com:3000/notifications/",
        body: {"uid": widget.channelName});
        print(result.body);
  }
}
