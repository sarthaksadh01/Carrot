import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps/steps.dart';
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
  int level = 0;
  String _userName = "";

  bool loading = true;
  FirebaseAuth auth;
  FirebaseUser user;
  String userUid;

  List<ProfileCard> list = [];
  List<dynamic> badges = [];

  @override
  void initState() {
    _loadData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                                      "$_userName",
                                      style: Theme.of(context).textTheme.title,
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    InkWell(
                                        child: _buildBadge(),
                                        onTap: () => showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  _showSteps(),
                                            )),
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
                                    backgroundImage:
                                        AssetImage('assets/images/logob.png'),
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
            bottomNavigationBar: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: InkWell(
                    onTap: () async {
                    },
                    child: Container(
                      height: 45,
                      // width:100 ,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFf45d27), Color(0xFFf5851f)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Center(
                          child: Text(
                        "Wallet",
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                ),
    );
  }

  Widget _buildBadge() {
    if (badges.length == 0) {
      _chechkLevel();
      badges.add({
        'color': Colors.white,
        'background': 1 == level ? Color(0xfffd6a02) : Colors.blue,
        'label': 1.toString(),
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.whatshot),
            Text(
              'Beginner',
              style: TextStyle(fontSize: 12.0),
            ),
            1 == level ? Text("You are here!") : Text("")
          ],
        ),
      });
      badges.add({
        'color': Colors.white,
        'background': 2 == level ? Color(0xfffd6a02) : Colors.blue,
        'label': 2.toString(),
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(FontAwesomeIcons.userNinja),
            Text(
              'Ninja',
              style: TextStyle(fontSize: 12.0),
            ),
            2 == level ? Text("You are here!") : Text("")
          ],
        ),
      });
      badges.add({
        'color': Colors.white,
        'background': 3 == level ? Color(0xfffd6a02) : Colors.blue,
        'label': 3.toString(),
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(FontAwesomeIcons.ghost),
            Text(
              'Ghost',
              style: TextStyle(fontSize: 12.0),
            ),
            3 == level ? Text("(You are here!)") : Text("")
          ],
        ),
      });
      badges.add({
        'color': Colors.white,
        'background': 4 == level ? Color(0xfffd6a02) : Colors.blue,
        'label': 4.toString(),
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(FontAwesomeIcons.chessKnight),
            Text(
              'Knight',
              style: TextStyle(fontSize: 12.0),
            ),
            4 == level ? Text("You are here!") : Text("")
          ],
        ),
      });
      badges.add({
        'color': Colors.white,
        'background': 5 == level ? Color(0xfffd6a02) : Colors.blue,
        'label': 5.toString(),
        'content': Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(FontAwesomeIcons.chessKing),
            Text(
              'King',
              style: TextStyle(fontSize: 12.0),
            ),
            5 == level ? Text("You are here!") : Text("")
          ],
        ),
      });
    }

    var _icon;
    if (level == 1)
      _icon = Icon(Icons.whatshot);
    else if (level == 2)
      _icon = Icon(FontAwesomeIcons.userNinja);
    else if (level == 3)
      _icon = Icon(FontAwesomeIcons.ghost);
    else if (level == 4)
      _icon = Icon(FontAwesomeIcons.chessKnight);
    else
      _icon = Icon(FontAwesomeIcons.crown);

    return _icon;
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
          _userName = doc.data['username'];
          level = doc.data['level'];
          loading = false;
        });
      });
    });
  }

  _showSteps() {
    return Scaffold(
        appBar: AppBar(
          title: Text("Popularity!"),
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          alignment: Alignment.topCenter,
          child: Steps(
              direction: Axis.vertical,
              size: 20.0,
              path: {'color': Colors.lightBlue.shade200, 'width': 3.0},
              steps: badges),
        ));
  }

  _chechkLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int tempLevel;
    int algo = (_likes / 2 + _viewers / 1.5 + _followers).round();
    if (algo < 10)
      tempLevel = 1;
    else if (algo >= 10 && algo < 100)
      tempLevel = 2;
    else if (algo >= 100 && algo < 1000)
      tempLevel = 3;
    else if (algo >= 1000 && algo < 10000)
      tempLevel = 4;
    else if (algo >= 100000) tempLevel = 5;
    print(level);
    print(tempLevel);
    if (tempLevel != level) {
      Firestore.instance.collection("Users").document(user.uid).updateData({"level":tempLevel}).then((onValue){

 
      });
      await prefs.setInt('level', tempLevel);
    }
  }
}
