import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import './agora_utils/videosession.dart';
import './agora_utils/settings.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoLive extends StatefulWidget {
  final String channelName, category, hashtags, title, username;

  /// Creates a call page with given channel name.
  const GoLive(
      {Key key, this.channelName, this.category, this.hashtags, this.title,this.username})
      : super(key: key);

  @override
  _GoLiveState createState() {
    return new _GoLiveState();
  }
}

class _GoLiveState extends State<GoLive> {
  static final _sessions = List<VideoSession>();
  final _infoStrings = <String>[];
  bool muted = false;
  String msg_uid;

  @override
  void dispose() {
    // clean up native views & destroy sdk
    _sessions.forEach((session) {
      AgoraRtcEngine.removeNativeView(session.viewId);
    });
    _sessions.clear();
    _leaveChanel();
    AgoraRtcEngine.leaveChannel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    // s _leaveChanel();
  }

  void initialize() {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings
            .add("APP_ID missing, please provide your APP_ID in settings.dart");
        _infoStrings.add("Agora Engine is not starting");
      });
      return;
    }

    _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // use _addRenderView everytime a native video view is needed
    _addRenderView(0, (viewId) {
      AgoraRtcEngine.setupLocalVideo(viewId, VideoRenderMode.Hidden);
      AgoraRtcEngine.startPreview();
      // state can access widget directly
      AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
    });
  }

  /// Create agora sdk instance and initialze
  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create(APP_ID);
    AgoraRtcEngine.enableVideo();
    AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    AgoraRtcEngine.setClientRole(ClientRole.Broadcaster);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (int code) {
      setState(() {
        String info = 'onError: ' + code.toString();
        // _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      _updateDatabase();
      setState(() {
        String info = "Yo Are Live";
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _leaveChanel();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        String info = 'userJoined: ' + uid.toString();
        // _infoStrings.add(info);
        _addRenderView(uid, (viewId) {
          AgoraRtcEngine.setupRemoteVideo(viewId, VideoRenderMode.Hidden, uid);
        });
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        String info = 'userOffline: ' + uid.toString();
        // _infoStrings.add(info);
        // _leaveChanel();
        _removeRenderView(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame =
        (int uid, int width, int height, int elapsed) {
      setState(() {
        String info = 'firstRemoteVideo: ' +
            uid.toString() +
            ' ' +
            width.toString() +
            'x' +
            height.toString();
        _infoStrings.add(info);
      });
    };
  }

  /// Create a native view and add a new video session object
  /// The native viewId can be used to set up local/remote view
  void _addRenderView(int uid, Function(int viewId) finished) {
    Widget view = AgoraRtcEngine.createNativeView(uid, (viewId) {
      setState(() {
        _getVideoSession(uid).viewId = viewId;
        if (finished != null) {
          finished(viewId);
        }
      });
    });
    VideoSession session = VideoSession(uid, view);
    _sessions.add(session);
  }

  /// Remove a native view and remove an existing video session object
  void _removeRenderView(int uid) {
    VideoSession session = _getVideoSession(uid);
    if (session != null) {
      _sessions.remove(session);
    }
    AgoraRtcEngine.removeNativeView(session.viewId);
  }

  /// Helper function to filter video session with uid
  VideoSession _getVideoSession(int uid) {
    return _sessions.firstWhere((session) {
      return session.uid == uid;
    });
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    return _sessions.map((session) => session.view).toList();
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    List<Widget> wrappedViews =
        views.map((Widget view) => _videoView(view)).toList();
    return Expanded(
        child: Row(
      children: wrappedViews,
    ));
  }

  /// Video layout wrapper
  Widget _viewRows() {
    List<Widget> views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            // _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () => _onToggleMute(),
            child: new Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: new Icon(
              Icons.videocam_off,
              color: Colors.white,
              size: 35.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: () => _onSwitchCamera(),
            child: new Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

// Info panel to show logs
  Widget _panel() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: ListView.builder(
                  reverse: true,
                  itemCount: _infoStrings.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_infoStrings.length == 0) {
                      return null;
                    }
                    return Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Flexible(
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: Color(0xfffd6a02),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(_infoStrings[index],
                                      style:
                                          TextStyle(color: Colors.blueGrey))))
                        ]));
                  })),
        ));
  }

  void _onCallEnd(BuildContext context) {
    _leaveChanel();
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xfffd6a02),
          title: Text("Live"),
        ),
        backgroundColor: Colors.black,
        body: Center(
            child: Stack(
          children: <Widget>[_viewRows(), _panel(), _toolbar()],
        )));
  }

  _updateDatabase() {
    print(widget.title);
    msg_uid = widget.channelName + randomString(10);
    Firestore.instance.collection('Live').add({
      'category': widget.category,
      'uid': widget.channelName,
      'username':widget.username,
      'msg_uid': msg_uid,
      'hashtags': widget.hashtags,
      'viewers': 0,
      'total_viewers': 0,
      'time': new DateTime.now().millisecondsSinceEpoch,
      'status': 'online',
      'title': widget.title
    }).then((onValue) {
      // Navigator.pushReplacementNamed(context, '/Home');
    }).catchError((e) {});
    // _onDisconnect();
  }

  _leaveChanel() {
    Firestore.instance
        .collection('Live')
        .where('msg_uid', isEqualTo: msg_uid)
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

  _onDisconnect() {
    Firestore.instance
        .collection('Live')
        .where('msg_uid', isEqualTo: msg_uid)
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
}
