import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  TabController controller;
  String user_uid;
  String name = " ";
  bool loading = true;
  @override
  void initState() {
    loadData();
    controller = TabController(initialIndex: 0, length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            actions: <Widget>[Icon(Icons.add)],
            // centerTitle:true ,
             title: Text("Profile"),
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Text(
                    name[0],
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
            backgroundColor: Color(0xfffd6a02),
            // bottom:

            // TabBar(
            //   tabs: <Widget>[
            //     Icon(Icons.info),
            //     Icon(Icons.file_upload),
            //     Icon(Icons.subscriptions),
            //     Icon(Icons.portrait),
            //     // Icon(Icons.),
            //   ],
            //    controller: controller,
            // ),
          ),
          SliverFillRemaining(
              child: Center(
                  child: loading == false
                      ? StreamBuilder(
                          stream: Firestore.instance
                              .collection('Users')
                              .document(user_uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return new CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              );
                            }
                            var userDocument = snapshot.data;

                            return new ListView(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.portrait,
                                      color: Color(0xfffd6a02)),
                                  title: Text("Username"),
                                  subtitle: Text(userDocument["username"]),
                                ),
                                ListTile(
                                  leading: Icon(Icons.email,
                                      color: Color(0xfffd6a02)),
                                  title: Text("Email"),
                                  subtitle: Text(userDocument["email"]),
                                ),
                                ListTile(
                                  leading: Icon(Icons.phone,
                                      color: Color(0xfffd6a02)),
                                  title: Text("Phone Number"),
                                  subtitle: Text(userDocument["phone"]),
                                ),
                                ListTile(
                                  leading: Icon(Icons.blur_circular,
                                      color: Color(0xfffd6a02)),
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
                          })
                      : CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            Color(0xfffd6a02),
                          ),
                        ))

              // TabBarView(

              //    controller: controller,
              //   children: <Widget>[
              //     Center(child: Text("Tab one")),
              //     Center(child: Text("Tab two")),
              //     Center(child: Text("Tab three")),
              //     Center(child: Text("Tab Four")),
              //   ],
              // ),
              ),
        ],
      ),
      bottomNavigationBar: LinearPercentIndicator(
        center: Text('Level 1'),
        width: MediaQuery.of(context).size.width,
        lineHeight: 14.0,
        percent: 1/10,
        backgroundColor: Colors.white,
        progressColor:Color(0xfffd6a02),
      ),
    );
  }

  loadData() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    setState(() {
      user_uid = user.uid;
      loading = false;
    });
  }
}
