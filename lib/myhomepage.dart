import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:loader_search_bar/loader_search_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:achievement_view/achievement_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import './adddesc.dart';
import './search/search.dart';
import './main_pages/categories.dart';
import './main_pages/home.dart';
import './main_pages/following.dart';
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String userImage = " ";
  bool logout = false;
  FirebaseAuth auth;
  FirebaseUser user;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Categories categories = new Categories();
  Home home = new Home();
  Following following = new Following();
  String addOption;
  var currentPage;
  @override
  void initState() {
    currentPage = home;
    _loadUser();
    _showAchievment();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SearchBar(
            searchHint: 'Search hashtags',
            defaultBar: AppBar(
              // leading: Icon(Icons.games),
              backgroundColor: Color(0xfffd6a02),
              title: Text("Carrot"),
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      icon: Icon(
                        Icons.portrait,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/Profile');
                      },
                    )),
                     Padding(
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      icon: Icon(
                        Icons.pages,
                        size: 30,
                      ),
                      onPressed: () {
                       _launchFaq();
                      },
                    ))
              ],
            ),
            onQuerySubmitted: (query) {
              Navigator.of(context).push(new MaterialPageRoute(
                  settings: const RouteSettings(name: '/Search'),
                  builder: (context) => new Search(
                        search: query.trim(),
                      )));
            }),
        body: currentPage,
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(80),
                    child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xfffd6a02),
                        backgroundImage: NetworkImage(userImage))),
                _profileData(),
                //  Spacer(),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/Login');
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
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xfffd6a02),
            onPressed: () {
              add();
            },
            child: Icon(Icons.add_circle)),
        bottomNavigationBar: FancyBottomNavigation(
          circleColor: Color(0xfffd6a02),
          inactiveIconColor: Color(0xfffd6a02),
          tabs: [
            TabData(iconData: Icons.home, title: "Home"),
            // TabData(iconData: Icons.add_circle, title: "Add"),
            TabData(iconData: Icons.category, title: "Categories"),
            TabData(iconData: Icons.group, title: "Following"),
          ],
          onTabChangedListener: (position) {
            setState(() {
              if (position == 0) currentPage = home;
              // if(position==1) {
              //   add();
              //   position=0;
              // }
              if (position == 1) currentPage = categories;
              if (position == 2) currentPage = following;
            });
          },
        ));
  }

  void add() {
    Alert(
        context: context,
        title: "Select an Option",
        desc: "You can go live either through device Camera or Screen Sharing",
        // image: Image.asset("assets/images/logob.png",height: 100,),
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(
                  settings: const RouteSettings(name: '/AddDesc'),
                  builder: (context) => new AddDescFull(
                        media: "Camera",
                      )));
            },
            child: Text(
              "Camera",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(
                  settings: const RouteSettings(name: '/AddDesc'),
                  builder: (context) => new AddDescFull(
                        media: "ScreenRecord",
                      )));
            },
            child: Text(
              "Screen",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  _loadUser() async {
    auth = FirebaseAuth.instance;
    user = await auth.currentUser();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
    Firestore.instance.collection('Users').document(user.uid).get().then((doc) {
      _firebaseMessaging.subscribeToTopic(doc.data["username"]);
      for (int i = 0; i < doc.data['following'].length; i++) {
        print(doc.data['following'][i]);
        _firebaseMessaging
            .subscribeToTopic(doc.data['following'][i].toString());
      }
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  Widget _profileData() {
    setState(() {});
    print("hello");
    if (user == null) return Container();
    return StreamBuilder(
        stream: Firestore.instance
            .collection('Users')
            .document(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new CircularProgressIndicator();
          }
          var userDocument = snapshot.data;

          userImage = userDocument["pic"];

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
                subtitle: Text("\u20B9 ${userDocument["wallet"]}"),
              ),
            ],
          );
        });
  }

  _showAchievment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int level = prefs.getInt('level') ?? 0;
    print(level);
    if (level == 0) return;
    if (level == 2) {
      AchievementView(context,
          title: "Yeaaah!",
          subTitle: "you are now a ninja",
          icon: Icon(
            FontAwesomeIcons.userNinja,
            color: Colors.white,
          ),
          isCircle: true, listener: (status) {
        print(status);
      })
        ..show();
      await prefs.setInt('level', 0);
    }
    if (level == 3) {
      AchievementView(context,
          title: "Yeaaah!",
          subTitle: "you are now a Ghost",
          icon: Icon(
            FontAwesomeIcons.ghost,
            color: Colors.white,
          ),
          isCircle: true, listener: (status) {
        print(status);
      })
        ..show();
      await prefs.setInt('level', 0);
    }
    if (level == 4) {
      AchievementView(context,
          title: "Yeaaah!",
          subTitle: "you are now a Knight",
          icon: Icon(
            FontAwesomeIcons.chessKnight,
            color: Colors.white,
          ),
          isCircle: true, listener: (status) {
        print(status);
      })
        ..show();
      await prefs.setInt('level', 0);
    }
    if (level == 5) {
      AchievementView(context,
          title: "Yeaaah!",
          subTitle: "you are now a King",
          icon: Icon(
            FontAwesomeIcons.chessKing,
            color: Colors.white,
          ),
          isCircle: true, listener: (status) {
        print(status);
      })
        ..show();

      await prefs.setInt('level', 0);
    }
  }
_launchFaq() async {
  const url = 'http://sarthaksadh.tech';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }

}
}