import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_color/random_color.dart';
import './other_profile.dart';
import './main_pages/viewlive.dart';
import 'dart:ui';

class CardLayout extends StatefulWidget {
  final String uid, username, msgUid, title, category, hashtags, img, docId;
  final likesList, viewers, commentList;

  CardLayout(
      {this.uid,
      this.username,
      this.msgUid,
      this.title,
      this.category,
      this.hashtags,
      this.img,
      this.docId,
      this.likesList,
      this.viewers,
      this.commentList});
  @override
  CardLayout_State createState() => CardLayout_State();
}

class CardLayout_State extends State<CardLayout> {
  RandomColor _randomColor;
  Color _color;
  bool liked = false;
  int _noOfLikes=0;
  @override
  void initState() {
    _randomColor = RandomColor();
    _color = _randomColor.randomColor();
    _isLikedByUser();
    _noOfLikes=widget.likesList.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text(widget.username[0]),
                ),
              ),
              InkWell(
                onTap: () async {
                  FirebaseAuth auth = FirebaseAuth.instance;
                  FirebaseUser user = await auth.currentUser();
                  if (user.uid == widget.uid) {
                    Navigator.of(context).pushNamed('/Profile');
                  } else {
                    Navigator.of(context).push(new MaterialPageRoute(
                        settings: const RouteSettings(name: '/OtherProfile'),
                        builder: (context) => new OtherProfile(
                              uid: widget.uid,
                              fullName: widget.username,
                            )));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.username,
                    style: TextStyle(fontSize: 17, color: Color(0xfffd6a02)),
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          InkWell(
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute(
                  settings: const RouteSettings(name: '/ViewLive'),
                  builder: (context) => new ViewLive(
                        channelName: widget.uid,
                        msgUid: widget.msgUid,
                        docId: widget.docId,
                      )));
            },
            child: Stack(
              children: <Widget>[
                Image.network(
                  widget.img,
                  height: 250,
                ),
                new Center(
                  child: new ClipRect(
                    child: new BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: new Container(
                        // width: 200.0,
                        height: 250.0,
                        decoration: new BoxDecoration(
                            color: Colors.grey.shade200.withOpacity(0.3)),
                        child: new Center(
                            child: Icon(
                          Icons.play_circle_filled,
                          size: 70,
                          color: Color(0xfffd6a02),
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${widget.title} | ${widget.category}",
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${widget.hashtags}",
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  FontAwesomeIcons.solidHeart,
                  size: 10,
                  color: Colors.red,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("$_noOfLikes"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  FontAwesomeIcons.solidComment,
                  size: 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("${widget.commentList.length}"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  FontAwesomeIcons.solidEye,
                  color: Colors.teal,
                  size: 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text("${widget.viewers.length}"),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 10),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    // FontAwesomeIcons.solidHeart,
                    liked
                        ? FontAwesomeIcons.solidHeart
                        : FontAwesomeIcons.heart,
                    color: Colors.red,
                  ),
                  onPressed: () => _likeUnlike(),
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.comment,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        settings: const RouteSettings(name: '/ViewLive'),
                        builder: (context) => new ViewLive(
                              channelName: widget.uid,
                              msgUid: widget.msgUid,
                              docId: widget.docId,
                            
                            )));
                  },
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.shareSquare,
                    color: Colors.black,
                  ),
                  onPressed: () => null,
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
    );
  }

  _isLikedByUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    for (int i = 0; i < widget.likesList.length; i++) {
      if (widget.likesList[i] == user.uid) {
        setState(() {
          liked = true;
        });

        break;
      }
    }
  }

  _likeUnlike() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser user = await auth.currentUser();
    if (liked) {
      setState(() {
        liked = false;
        _noOfLikes-=1;
      });
      Firestore.instance.collection('Live').document(widget.docId).updateData({
        'likes': FieldValue.arrayRemove([user.uid])
      });
    } else {
      setState(() {
        liked = true;
        _noOfLikes+=1;
      });
      Firestore.instance.collection('Live').document(widget.docId).updateData({
        'likes': FieldValue.arrayUnion([user.uid])
      });
    }
  }
}
