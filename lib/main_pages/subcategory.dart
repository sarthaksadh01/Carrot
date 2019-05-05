import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './viewlive.dart';
import '../other_profile.dart';

class SubCategoryFull extends StatefulWidget {
  final String sub;
  SubCategoryFull({this.sub});
  @override
  _SubCategoryFullState createState() => _SubCategoryFullState();
}

class _SubCategoryFullState extends State<SubCategoryFull> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sub),
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('Live')
              .where('status', isEqualTo: 'online')
              .where('category', isEqualTo: widget.sub)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return new CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Color(0xfffd6a02),
                ),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  return Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                FirebaseAuth auth = FirebaseAuth.instance;
                                FirebaseUser user = await auth.currentUser();
                                if (user.uid == ds['uid']) {
                                  Navigator.of(context).pushNamed('/Profile');
                                } else {
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          settings: const RouteSettings(
                                              name: '/OtherProfile'),
                                          builder: (context) =>
                                              new OtherProfile(
                                                uid: ds['uid'],
                                                fullName: ds['username'],
                                              )));
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  ds['username'],
                                  style: TextStyle(
                                      fontSize: 17, color: Color(0xfffd6a02)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(new MaterialPageRoute(
                                settings:
                                    const RouteSettings(name: '/ViewLive'),
                                builder: (context) => new ViewLive(
                                      channelName: ds['uid'],
                                      msgUid: ds['msg_uid'],
                                    )));
                          },
                          child: Stack(
                            children: <Widget>[
                              Image.asset(
                                'assets/images/logob.png',
                                height: 100,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${ds['title']} | ${ds['category']}",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${ds['hashtags']}",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w300),
                              ),
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
                  );
                });
          }),
    );
  }
}
