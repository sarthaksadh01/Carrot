import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:random_color/random_color.dart';
import './other_profile.dart';

class SingleUserLayout extends StatelessWidget {
  final String username, uid,uPic;
  final followersList;
  final int level;
  SingleUserLayout({this.username, this.uid, this.followersList, this.level,this.uPic});
  @override
  Widget build(BuildContext context) {
    RandomColor _randomColor;
    Color _color;
    _randomColor = RandomColor();
    _color = _randomColor.randomColor();
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 5),
                child: CircleAvatar(
                  backgroundColor: _color,
                   backgroundImage:NetworkImage(uPic) ,
                 
                ),
              ),
              InkWell(
                onTap: () {
                  _navigateToProfile(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    username,
                    style: TextStyle(fontSize: 17, color: Color(0xfffd6a02)),
                  ),
                ),
              ),
              Spacer(),
              IconButton(
                icon: _buildBadge(),
                onPressed: () {
                  _navigateToProfile(context);
                },
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Icon(FontAwesomeIcons.users),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text("${followersList.length}"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _navigateToProfile(context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    if (user.uid == uid) {
      Navigator.of(context).pushNamed('/Profile');
    } else {
      Navigator.of(context).push(new MaterialPageRoute(
          settings: const RouteSettings(name: '/OtherProfile'),
          builder: (context) => new OtherProfile(
                uid: uid,
                fullName: username,
              )));
    }
  }

  Widget _buildBadge() {
    var _icon;
    if (level == 1)
      _icon = Icon(Icons.whatshot,color: Color(0xfffd6a02));
    else if (level == 2)
      _icon = Icon(FontAwesomeIcons.userNinja,color: Color(0xfffd6a02));
    else if (level == 3)
      _icon = Icon(FontAwesomeIcons.ghost,color: Color(0xfffd6a02));
    else if (level == 4)
      _icon = Icon(FontAwesomeIcons.chessKnight,color: Color(0xfffd6a02));
    else
      _icon = Icon(FontAwesomeIcons.crown,color: Color(0xfffd6a02));

    return _icon;
  }
}
