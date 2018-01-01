import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class OtherProfile extends StatefulWidget {
  OtherProfile({this.fullName, this.uid});
  final String fullName, uid;
  @override
  _OtherProfileState createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
  int _followers = 0;
  int _uploads = 0;
  int _level = 0;
  bool loading = true;
  bool _isFollowing = false;
  bool followLoading = true;
  bool isNotified = false;
  FirebaseAuth auth;
  // =
  FirebaseUser user;
  // =
  @override
  void initState() {
    _loadUser();
    _loadData();
    loadIsFollowed();

    super.initState();
  }

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.6,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://pub-static.haozhaopian.net/assets/projects/pages/7dc25bd0-93c5-11e8-bb5f-571eb52efbb2_1ede0186-8709-4911-ad8a-ec6ace3ef05b_thumb.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://cdn.pixabay.com/photo/2017/02/23/13/05/profile-2092113_960_720.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    TextStyle _statLabelTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.w200,
    );

    TextStyle _statCountTextStyle = TextStyle(
      color: Colors.black54,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );

    return label != "icon"
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '$count',
                style: _statCountTextStyle,
              ),
              Text(
                label,
                style: _statLabelTextStyle,
              )
            ],
          )
        : IconButton(
            icon: isNotified == false
                ? Icon(Icons.notifications)
                : Icon(Icons.notifications_off),
            onPressed: () {
              if (isNotified)
                _notNotified();
              else {
                _notified();
              }
            },
          );
  }

  Widget _buildStatContainer() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Followers", _followers),
          _buildStatItem("Uploads", _uploads),
          _buildStatItem("Level", _level),
          _buildStatItem("icon", _level),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: _isFollowing
                  ? () {
                      _unfollow();
                    }
                  : () {
                      _follow();
                    },
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: Color(0xfffd6a02),
                ),
                child: Center(
                  child: _isFollowing
                      ? followLoading == false
                          ? Text(
                              "UNFOLLOW",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : FlareActor(
                              "assets/flare/loading.flr",
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              animation: "Untitled",
                            )
                      : followLoading == false
                          ? Text(
                              "FOLLOW",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : FlareActor(
                              "assets/flare/loading.flr",
                              alignment: Alignment.center,
                              fit: BoxFit.contain,
                              animation: "Untitled",
                            ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: InkWell(
              onTap: () => print("Message"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "DONATE",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fullName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xfffd6a02),
      ),
      body: loading == false
          ? Stack(
              children: <Widget>[
                _buildCoverImage(screenSize),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: screenSize.height / 6.4),
                        _buildProfileImage(),
                        _buildStatContainer(),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: FlareActor(
                "assets/flare/loading.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: "Untitled",
              ),
            ),
      bottomNavigationBar: _buildButtons(),
    );
  }

  _loadUser() async {
    auth = FirebaseAuth.instance;
    user = await auth.currentUser();
  }

  _loadData() {
    Firestore.instance
        .collection('Live')
        .where('uid', isEqualTo: widget.uid)
        .getDocuments()
        .then((docs) {
      docs.documents.forEach((doc) {
        setState(() {
          _uploads++;
        });
      });

      Firestore.instance
          .collection('Users')
          .document(widget.uid)
          .get()
          .then((doc) {
        List<String> flwrs = List.from(doc.data['followers']);
        for (int i = 0; i < flwrs.length; i++) {
          if (flwrs[i] == user.uid) {
            setState(() {
              _isFollowing = true;
            });
          }
        }
        setState(() {
          _followers = flwrs.length;
          loading = false;
          followLoading = false;
        });
      });
    });
  }

   loadIsFollowed() {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((token) {
      Firestore.instance
          .collection("Users")
          .document(widget.uid)
          .get()
          .then((doc) {
        var notificationArray = doc.data['notifications'];
        for (int i = 0; i < notificationArray.length; i++) {
          if (notificationArray[i] == token.toString()) {
            setState(() {
              isNotified=true;
              
            });
            break;
          }
        }
      });
      print(token);
    });


  }

  _notNotified() {
    setState(() {
      isNotified = false;
    });
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((token) {
      Firestore.instance.collection("Users").document(widget.uid).updateData({
        "notifications": FieldValue.arrayRemove([token])
      }).then((onValue) {});
    });
  }

  _notified() {
    setState(() {
      isNotified = true;
    });
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((token) {
      Firestore.instance.collection("Users").document(widget.uid).updateData({
        "notifications": FieldValue.arrayUnion([token])
      }).then((onValue) {});
    });
  }

  _unfollow() {
    setState(() {
      followLoading = true;
    });
    List<String> by = [user.uid];
    Firestore.instance
        .collection('Users')
        .document(widget.uid)
        .updateData({'followers': FieldValue.arrayRemove(by)}).then((onValue) {
      setState(() {
        followLoading = false;
        _isFollowing = false;
        _followers--;
      });
    });
  }

  _follow() async {
    setState(() {
      followLoading = true;
    });
    List<dynamic> by = [user.uid];
    Firestore.instance
        .collection('Users')
        .document(widget.uid)
        .updateData({'followers': FieldValue.arrayUnion(by)}).then((onValue) {
      setState(() {
        followLoading = false;
        _isFollowing = true;
        _followers++;
      });
    });

    print("follow called");
  }
}
