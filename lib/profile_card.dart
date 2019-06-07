import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class ProfileCard extends StatelessWidget {
  final String img,title,category;
  final commentList,viewers,likeList;
  ProfileCard({this.img,this.title,this.category,this.commentList,this.viewers,this.likeList});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width/2,
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: <Widget>[
            Stack(
                children: <Widget>[
                  Image.asset(
                    'assets/images/logob.png',
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
                              color: Colors.grey.shade200.withOpacity(0.2)),
                          // child: new Center(
                          //     child: Icon(

                          //   Icons.videocam,
                          //   size: 70,
                          //   color: Color(0xfffd6a02),
                          // )),
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
                        "$title | $category",
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                  child: Text("${likeList.length}"),
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
                  child: Text("${commentList.length}"),
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
                  child: Text("${viewers.length}"),
                ),
              ],
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        margin: EdgeInsets.all(10),
      ),
    );
  }
}