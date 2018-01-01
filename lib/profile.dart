import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _followers = 0;
  int _uploads = 0;
  int _level = 0;
  bool loading = true;
  FirebaseAuth auth;
  // =
  FirebaseUser user;
  String userUid;
  // =
  @override
  void initState() {
    _loadData();

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

  Widget _buildStatItem(
    String label,
    int count,
  ) {
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '$count',
          style: _statCountTextStyle,
        ),
        Text(
          label,
          style: _statLabelTextStyle,
        ),
      ],
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
          
        ],
      ),
    );
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
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "profile",
          // widget.fullName,
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
                        _profileData()
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
        });
      });

      Firestore.instance
          .collection('Users')
          .document(user.uid)
          .get()
          .then((doc) {
        List<String> flwrs = List.from(doc.data['followers']);
        setState(() {
          _followers = flwrs.length;
          loading = false;
        });
      });
    });
  }
}
