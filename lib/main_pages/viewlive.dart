import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import './agora_utils/videosession.dart';
import './agora_utils/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewLive extends StatefulWidget {
  final String channelName, msgUid;

  /// Creates a call page with given channel name.
  const ViewLive({Key key, this.channelName, this.msgUid}) : super(key: key);

  @override
  _GoLiveState createState() {
    return new _GoLiveState();
  }
}

class _GoLiveState extends State<ViewLive> {
  static final _sessions = List<VideoSession>();
  final _infoStrings = <String>[];
  bool muted = false;
  bool chat=true;
  String msg;

  @override
  void dispose() {
    // clean up native views & destroy sdk
    _sessions.forEach((session) {
      AgoraRtcEngine.removeNativeView(session.viewId);
    });
    _sessions.clear();
    AgoraRtcEngine.leaveChannel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    print(widget.msgUid);
    initialize();
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
    AgoraRtcEngine.setClientRole(ClientRole.Audience);
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
      setState(() {
        String info = "You Are Live";
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        // _infoStrings.add('onLeaveChannel');
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
      child: chat==true?Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () {
              _toggleChat();
            },
            child: new Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 30.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Color(0xfffd6a02),
            padding: const EdgeInsets.all(15.0),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  msg = val;
                  val = "";
                });
              },
              decoration: new InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      new EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(12.0),
                  ),
                  hintText: 'Type here'),
            ),
          )),
          RawMaterialButton(
            onPressed: () {
              _sendMsg();
            },
            child: new Icon(
              Icons.send,
              color: Colors.white,
              size: 30.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Color(0xfffd6a02),
            padding: const EdgeInsets.all(15.0),
          ),
        ],
      ): RawMaterialButton(
            onPressed: () {
              _toggleChat();
            },
            child: new Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 30.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Color(0xfffd6a02),
            padding: const EdgeInsets.all(15.0),
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
              child: FirebaseAnimatedList(
                query: FirebaseDatabase.instance
                    .reference()
                    .child('Msg')
                    .orderByChild('msg_uid')
                    .equalTo(widget.msgUid),
                sort: (a, b) => b.key.compareTo(a.key),
                padding: new EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, DataSnapshot snapshot,
                    Animation<double> animation, int) {
                  return ListTile(
                    title: Text(
                      snapshot.value['name'],
                      style: TextStyle(color: Color(0xfffd6a02)),
                    ),
                    subtitle: Text(snapshot.value['msg'],
                        style: TextStyle(color: Colors.white)),
                  );
                },
              )),
        ));
  }

  // void _onCallEnd(BuildContext context) {
  //   Navigator.pop(context);
  // }

  void _sendMsg() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    final reference = FirebaseDatabase.instance.reference().child('Msg');
    reference.push().set({
      'msg': msg,
      'name': "Sarthak",
      'msg_uid': widget.msgUid,
      'sender_uid': user.uid,
      'time': new DateTime.now().millisecondsSinceEpoch,
    }).then((onValue) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => MyHomePage()),
      // );
    });
  }

  void _updateLive() {}
  void _toggleChat(){

    if(chat==true){
      setState(() {
        chat=false;
      });
    }
    else{
      setState(() {
        chat=true;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: chat==true?Stack(
          children: <Widget>[
            _viewRows(), _panel(), _toolbar()]
            
            ,
        ):Stack(
          children: <Widget>[
            _viewRows(), _toolbar()]
            
            ,
        )
        
        )
        );
  }
}
