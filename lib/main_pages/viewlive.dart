import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import './agora_utils/videosession.dart';
import './agora_utils/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter/services.dart';

class ViewLive extends StatefulWidget {
  final String channelName, msgUid, docId;

  /// Creates a call page with given channel name.
  const ViewLive(
      {Key key, this.channelName, this.msgUid, this.docId})
      : super(key: key);

  @override
  _GoLiveState createState() {
    return new _GoLiveState();
  }
}

class _GoLiveState extends State<ViewLive> {
  RandomColor _randomColor;
  Color _color;
  static final _sessions = List<VideoSession>();
  final _infoStrings = <String>[];
  bool muted = false;
  bool isFullScreen = false;
  String userName = "";
  bool liked;
  final TextEditingController _msg = new TextEditingController();
  

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _randomColor = RandomColor();
    _loadUserName();
    initialize();
    super.initState();
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
    AgoraRtcEngine.onWarning = (int code) {
      setState(() {
        String info = 'onWarning: ' + code.toString();
        Fluttertoast.showToast(
            msg: info,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xfffd6a02),
            textColor: Colors.white,
            fontSize: 16.0);
        // _infoStrings.add(info);
      });
    };
    AgoraRtcEngine.onError = (int code) {
      setState(() {
        String info = 'onError: ' + code.toString();
        Fluttertoast.showToast(
            msg: info,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xfffd6a02),
            textColor: Colors.white,
            fontSize: 16.0);
        // _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      setState(() {
        String info = "You Are Live";
        _infoStrings.add(info);
        _updateLive();
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {};

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

  /// Video layout wrapper
  Widget _viewRowsHalfScreen() {
    List<Widget> views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Column(
          // mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              child: views[0],
              height: 350,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.fullscreen, color: Colors.green, size: 30),
                  onPressed: () => _changeScreenRes(),
                ),
              ],
            ),
            Divider()
          ],
        );
        break;
      case 2:
        return isFullScreen == false
            ? Column(
                // mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: views[1],
                    height: 350,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.fullscreen,
                            color: Colors.green, size: 30),
                        onPressed: () => _changeScreenRes(),
                      ),
                    ],
                  ),
                  Divider()
                ],
              )
            : Expanded(child: Container(child: views[1]));

        break;

      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: TextField(
            controller: _msg,
            decoration: new InputDecoration(
                fillColor: Colors.white,
                filled: true,
                contentPadding: new EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 10.0),
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
    );
  }

// Info panel to show logs
  Widget _comments() {
    return Flexible(
        child: StreamBuilder(
      stream: Firestore.instance
          .collection('Live')
          .document(widget.docId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        // DocumentSnapshot ds = snapshot.data.document;
        print(snapshot.data['comments'].length);
        return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data['comments'].length,
            itemBuilder: (context, index) {
              _color = _randomColor.randomColor();
              ;
              return ListTile(
                title: Text(
                  snapshot.data['comments'][index]['name'],
                  style: TextStyle(color: _color, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  snapshot.data['comments'][index]['msg'],
                  style: TextStyle(color: Colors.black),
                ),
              );
            });
      },
    ));
  }

  void _sendMsg() async {
    if (userName == "") return;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    Firestore.instance.collection('Live').document(widget.docId).updateData({
      'comments': FieldValue.arrayUnion([
        {
          'msg': _msg.text,
          'name': userName,
          'sender_uid': user.uid,
          'time': new DateTime.now()
        }
      ])
    }).then((onValue) {
      _msg.clear();
    });
  }

  void _updateLive() async {
    bool _viewed = false;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    Firestore.instance
        .collection('Live')
        .where('msg_uid', isEqualTo: widget.msgUid)
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((doc) {
        for (int i = 0; i < doc['viewers'].length; i++) {
          if (doc['viewers'][i] == user.uid) _viewed = true;
        }

        if (!_viewed) {
          Firestore.instance
              .collection('Live')
              .document(doc.documentID)
              .updateData({
            'viewers': FieldValue.arrayUnion([user.uid])
          }).then((onValue) {
            print('done');
          });
        }
      });
    });
  }

  void _loadUserName() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    Firestore.instance.collection("Users").document(user.uid).get().then((doc) {
      setState(() {
        userName = doc.data['username'];
      });
    });
  }

  void _changeScreenRes() {
    print("back pressed");
    if (isFullScreen == false) {
      setState(() {
        isFullScreen = true;
      });
    } else {
      setState(() {
        isFullScreen = false;
      });
    }
    print(isFullScreen);
  }

  _onBackPressed() {
    if (isFullScreen) {
      setState(() {
        isFullScreen = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: isFullScreen == false
              ? <Widget>[_viewRowsHalfScreen(), _comments(), _toolbar()]
              : <Widget>[_viewRowsHalfScreen()],
        ),
        // bottomNavigationBar: _toolbar(),
      ),
      onWillPop: () => _onBackPressed(),
    );
  }
}
