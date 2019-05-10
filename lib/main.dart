import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:easy_dialogs/easy_dialogs.dart';
import 'package:loader_search_bar/loader_search_bar.dart';
import './comments.dart';
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
import './search.dart';


void main() {
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
      '/Apps': (context) => ListAppsPages(),
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
  Categories categories = new Categories();
  Home home = new Home();
  Private private = new Private();
  String addOption;
  var currentPage;
  @override
  void initState() {
    currentPage = home;

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
          title:Text("Carrot"),
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
        onQuerySubmitted: (query){

            Navigator.of(context).push(new MaterialPageRoute(
                      settings: const RouteSettings(name: '/Search'),
                      builder: (context) => new Search(
                            search: "#"+query.toLowerCase(),
                          )));

        }
        ),
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
        builder: (context) => SingleChoiceConfirmationDialog<String>(
            actionButtonLabelColor: Color(0xfffd6a02),
            activeColor: Color(0xfffd6a02),
            title: Text('Select Option'),
            items: ['Screen Recorder', 'Camera'],
            // onSelected: ,
            onSubmitted: (val) {
              setState(() {
                addOption = val;
                if (val == "Camera") {
                  Navigator.of(context).push(new MaterialPageRoute(
                      settings: const RouteSettings(name: '/AddDesc'),
                      builder: (context) => new AddDescFull(
                            media: "Camera",
                          )));

                  // Navigator.pushNamed(context, '/AddDesc');
                } else {
                  _getApps();
                  //  Navigator.of(context).push(new MaterialPageRoute(
                  //     settings: const RouteSettings(name: '/AddDesc'),
                  //     builder: (context) => new AddDescFull(
                  //           media: "ScreenRecord",
                  //         )));

                  // // _startScreenShare();
                }
              });
            }));
  }

  _getApps() {
    Navigator.of(context).pushNamed('/ScreenRecord');
  }
}
