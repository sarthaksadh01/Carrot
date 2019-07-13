import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:http/http.dart' as http;
import './profile_card.dart';
import './donate.dart';
import './url.dart';

class OtherProfile extends StatefulWidget {
  OtherProfile({this.fullName, this.uid});
  final String fullName, uid;
  @override
  _OtherProfileState createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
  String uPic = "";
  int _likes = 0;
  int _viewers = 0;
  int _followers = 0;
  int _uploads = 0;
  int _level = 0;
  bool loading = true;
  bool _isFollowing = false;
  bool followLoading = true;
  FirebaseAuth auth;
  FirebaseUser user;
  List<ProfileCard> list = [];
  @override
  void initState() {
    _loadUser();

    super.initState();
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
                            : CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              )
                        : followLoading == false
                            ? Text(
                                "FOLLOW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              )),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    settings: const RouteSettings(name: '/SignUpB'),
                    builder: (context) => Donate(
                          uid: widget.uid,
                        )));
              },
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
    final String url =
        'https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/09/04/15/lionel-messi-0.jpg?';
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
          ? SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        height: 250.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xFFf45d27), Color(0xFFf5851f)]),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 50.0),
                        height: 240.0,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  top: 40.0,
                                  left: 40.0,
                                  right: 40.0,
                                  bottom: 10.0),
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                elevation: 5.0,
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 50.0,
                                    ),
                                    Text(
                                      "${widget.fullName}",
                                      style: Theme.of(context).textTheme.title,
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Icon(Icons.whatshot),
                                    SizedBox(
                                      height: 16.0,
                                    ),
                                    Container(
                                      height: 40.0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            child: ListTile(
                                              title: Text(
                                                "$_uploads",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                  "Uploads".toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12.0)),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              title: Text(
                                                "$_followers",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                  "Followers".toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12.0)),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              title: Text(
                                                "$_likes",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                  "Likes".toUpperCase(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 12.0)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Material(
                                  elevation: 5.0,
                                  shape: CircleBorder(),
                                  child: CircleAvatar(
                                    radius: 40.0,
                                    backgroundImage: NetworkImage(uPic),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
                      child: Text("Uploads",
                          style: Theme.of(context).textTheme.title)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List<Widget>.generate(list.length, (index) {
                        return list[index];
                      }),
                    ),
                  ),
                ],
              ),
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
    _loadData();
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
          _likes += doc.data['likes'].length;
          _viewers += doc.data['viewers'].length;
          ProfileCard profileCard = new ProfileCard(
            img: doc.data['img'],
            title: doc.data['title'],
            category: doc.data['category'],
            likeList: doc.data['likes'],
            commentList: doc.data['comments'],
            viewers: doc.data['viewers'],
          );
          list.add(profileCard);
        });
      });

      print(list);

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
            break;
          }
        }
        setState(() {
          _followers = flwrs.length;
          loading = false;
          followLoading = false;
          uPic = doc.data['pic'];
        });
      });
    });
  }

  _unfollow() {
    setState(() {
      followLoading = true;
    });

    Firestore.instance.collection('Users').document(widget.uid).updateData({
      'followers': FieldValue.arrayRemove([user.uid])
    }).then((onValue) {
      Firestore.instance.collection('Users').document(user.uid).updateData({
        'following': FieldValue.arrayRemove([widget.uid])
      }).then((onValue) {
        setState(() {
          followLoading = false;
          _isFollowing = false;
          _followers--;
        });
      });
    });
  }

  _follow() async {
    setState(() {
      followLoading = true;
    });

    Firestore.instance.collection('Users').document(widget.uid).updateData({
      'followers': FieldValue.arrayUnion([user.uid])
    }).then((onValue) {
      Firestore.instance.collection('Users').document(user.uid).updateData({
        'following': FieldValue.arrayUnion([widget.uid])
      }).then((onValue) {
        setState(() {
          _sendFollowNotification();
          followLoading = false;
          _isFollowing = true;
          _followers++;
        });
      });
    });

    print("follow called");
  }

  _sendFollowNotification() async {
    var result = await http.post(URL + "/followNotifications/",
        body: {"uid": widget.uid, "followedBy": user.uid});
    print(result.body);
  }
}
