import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:loader_search_bar/loader_search_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './profile.dart';
import './main_pages/categories.dart';
import './main_pages/home.dart';
import './main_pages/private.dart';
import './adddesc.dart';
import './splashscreen.dart';
import './login.dart';
import './signup_a.dart';
import './signup_b.dart';
import './main_pages/subcategory.dart';
import './golive_screen.dart';
import './main_pages/viewlive.dart';
import './other_profile.dart';
import './search/search.dart';

void main() {
  Admob.initialize('ca-app-pub-3940256099942544~3347511713');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        primaryColor: Color(0xfffd6a02), accentColor: Color(0xfffd6a02)),
    title: 'Simosa',
    initialRoute: '/',
    routes: {
      '/': (context) => SplashFull(),
      '/Home': (context) => MyHomePage(),
      '/Login': (context) => LoginFull(),
      '/Profile': (context) => Profile(),
      '/AddDesc': (context) => AddDescFull(),
      '/SignUpA': (context) => SignupAFull(),
      '/SignUpB': (context) => SignupBFull(),
      '/Sub': (context) => SubCategoryFull(),
      '/ScreenRecord': (context) => ScreenRecord(),
      '/ViewLive': (context) => ViewLive(),
      '/OtherProfile': (context) => OtherProfile(),
      'Search': (context) => Search()
    },
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseAuth auth;
  FirebaseUser user;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Categories categories = new Categories();
  Home home = new Home();
  Private private = new Private();
  String addOption;
  var currentPage;
  @override
  void initState() {
    currentPage = home;
   _loadUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SearchBar(
            searchHint: 'Search hashtags',
            defaultBar: AppBar(
              leading: Icon(Icons.games),
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
            TabData(iconData: Icons.category, title: "Categories"),
            TabData(iconData: Icons.personal_video, title: "Private"),
            TabData(iconData: Icons.trending_up, title: "Trending")
          ],
          onTabChangedListener: (position) {
            setState(() {
              if (position == 0) currentPage = home;
              if (position == 1) currentPage = categories;
              if (position == 2) currentPage = private;
            });
          },
        ));
  }

  void add() {
    showDialog(
        context: context,
        builder: (_) => NetworkGiffyDialog(
              buttonCancelColor: Colors.green,
              onCancelButtonPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    settings: const RouteSettings(name: '/AddDesc'),
                    builder: (context) => new AddDescFull(
                          media: "Camera",
                        )));
              },
              image: Image.asset('assets/images/logob.png'),
              title: Text('Select an Option',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
              description: Text(
                'You can go live either through device camera or through screen sharing!',
                textAlign: TextAlign.center,
              ),
              onOkButtonPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    settings: const RouteSettings(name: '/AddDesc'),
                    builder: (context) => new AddDescFull(
                          media: "ScreenRecord",
                        )));
              },
            ));
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
   Firestore.instance.collection('Users').document(user.uid).get().then((doc){
     for(int i=0;i<doc.data['following'].length;i++){
       print(doc.data['following'][i]);
       _firebaseMessaging.subscribeToTopic(doc.data['following'][i].toString());
     }

   });
    // _firebaseMessaging.subscribeToTopic("topic");

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
}
