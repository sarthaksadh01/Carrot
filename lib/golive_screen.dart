import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScreenRecord extends StatefulWidget {
  final String channelName, category, title;
  final List<String> hashtags;
  const ScreenRecord(
      {Key key, this.channelName, this.category, this.hashtags, this.title})
      : super(key: key);

  @override
  _ScreenRecordState createState() => _ScreenRecordState();
}

class _ScreenRecordState extends State<ScreenRecord> {
  @override
  void initState() {
    // _startScreenShare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Start"),
              onPressed: (){
                _startScreenShare();
              },
            ),
            RaisedButton(
              child: Text("Stop"),
              onPressed: (){
                _stopScreenShare();
              },
            ),
          ],
        ),

      ),
    );
  }

  Future<void> _startScreenShare() async {
   FirebaseAuth auth = FirebaseAuth.instance;
   FirebaseUser user = await auth.currentUser();
    const platform = const MethodChannel('samples.flutter.io/screen_record');
    try {
      final String result = await platform.invokeMethod('startScreenShare',{"uid":user.uid});
      if(result=="started"){
        print("started");
      }

    } on PlatformException catch (e) {}

    setState(() {
      // _batteryLevel = batteryLevel;
    });
  }

  Future<void> _stopScreenShare() async {
  
    const platform = const MethodChannel('samples.flutter.io/screen_record');
    try {
      final String result = await platform.invokeMethod('stopScreenShare');
      if(result=="stopped"){
        print("stopped");
      }

    } on PlatformException catch (e) {}

    setState(() {
      // _batteryLevel = batteryLevel;
    });
  }
}
