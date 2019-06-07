import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './profile_card.dart';


class OtherProfile extends StatefulWidget {
  OtherProfile({this.fullName, this.uid});
  final String fullName, uid;
  @override
  _OtherProfileState createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
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
                SingleChildScrollView(
                                  child: Container(
                    padding: EdgeInsets.only(top: 16),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    decoration: BoxDecoration(
                      color: Color(0xfffd6a02),
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(32),
                          bottomLeft: Radius.circular(32)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(url))),
                            ),
                          ],
                        ),
                
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 32),
                          child: Text(
                            '${widget.fullName}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.videocam,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Uploads',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '$_uploads',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Likes',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '$_likes',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.solidEye,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Viewers',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '$_viewers',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.group,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Followers',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '$_followers',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
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
                  Text("Uploads",style: TextStyle(fontSize: 30),)

                ],),
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
          followLoading=false;
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
          followLoading = false;
          _isFollowing = true;
          _followers++;
        });
      });
    });

    print("follow called");
  }
}
