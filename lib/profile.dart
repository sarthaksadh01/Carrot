import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './profile_card.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _followers = 0;
  int _uploads = 0;
  int _likes = 0;
  int _viewers = 0;
  String _userName="";

  bool loading = true;
  FirebaseAuth auth;
  FirebaseUser user;
  String userUid;

  List<ProfileCard> list = [];

  @override
  void initState() {
    _loadData();

    super.initState();
  }




  Widget _profileData() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('Users')
            .document(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new FlareActor(
              "assets/flare/loading.flr",
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: "Untitled",
            );
          }
          var userDocument = snapshot.data;

          return new Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.portrait, color: Color(0xfffd6a02)),
                title: Text("Username"),
                subtitle: Text(userDocument["username"]),
              ),
              ListTile(
                leading: Icon(Icons.email, color: Color(0xfffd6a02)),
                title: Text("Email"),
                subtitle: Text(userDocument["email"]),
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Color(0xfffd6a02)),
                title: Text("Phone Number"),
                subtitle: Text(userDocument["phone"]),
              ),
              ListTile(
                leading: Icon(Icons.blur_circular, color: Color(0xfffd6a02)),
                title: Text("Gender"),
                subtitle: Text(userDocument["gender"]),
              ),
              ListTile(
                leading: Icon(Icons.account_balance_wallet,
                    color: Color(0xfffd6a02)),
                title: Text("Wallet"),
                subtitle: Text("0"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final String url =
        'https://static.independent.co.uk/s3fs-public/thumbnails/image/2018/09/04/15/lionel-messi-0.jpg?';
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        elevation: 0,
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
                            '$_userName',
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
    );
  }

  _loadData() async {
    auth = FirebaseAuth.instance;
    user = await auth.currentUser();
    Firestore.instance
        .collection('Live')
        .where('uid', isEqualTo: user.uid)
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
          .document(user.uid)
          .get()
          .then((doc) {
        List<String> flwrs = List.from(doc.data['followers']);
        setState(() {
          _followers = flwrs.length;
          _userName=doc.data['username'];
          loading = false;
        });
      });
    });
  }
}
