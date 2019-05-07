import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

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
    _startScreenShare();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> _startScreenShare() async {
    const platform = const MethodChannel('samples.flutter.io/screen_record');
    try {
      final int result = await platform.invokeMethod('startScreenShare');
    } on PlatformException catch (e) {}

    setState(() {
      // _batteryLevel = batteryLevel;
    });
  }
}
