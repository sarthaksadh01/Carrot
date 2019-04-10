import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  TabController controller;
  String uname="",email="",pno="",gender="";
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
            title: Text("sarthak sadh "),
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Text(
                    "S",
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
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.portrait, color: Color(0xfffd6a02)),
                  title: Text("Username"),
                  subtitle: Text(uname),
                ),
                ListTile(
                  leading: Icon(Icons.email, color: Color(0xfffd6a02)),
                  title: Text("Email"),
                  subtitle: Text(email),
                ),
                ListTile(
                  leading: Icon(Icons.phone, color: Color(0xfffd6a02)),
                  title: Text("Phone Number"),
                  subtitle: Text(pno),
                ),
                ListTile(
                  leading: Icon(Icons.gif, color: Color(0xfffd6a02)),
                  title: Text("Gender"),
                  subtitle: Text(gender),
                ),
                ListTile(
                  leading: Icon(Icons.account_balance_wallet,
                      color: Color(0xfffd6a02)),
                  title: Text("Wallet"),
                  subtitle: Text("0"),
                ),
              ],
            ),
          )

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
    );
  }

  loadData()async {
     final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
     Map<dynamic, dynamic> values;
     
  final db = FirebaseDatabase.instance.reference().child("Users").child(user.uid);
    db.once().then((DataSnapshot snapshot) {
      values=snapshot.value;
       values.forEach((key, values) {
         setState(() {
           if(key=="username"){
             setState(() {
               uname=values;
             });

           }
           if(key=="email"){
                setState(() {
               email=values;
             });
             
           }
           if(key=="gender"){
                setState(() {
               gender=values;
             });
             
           }
           if(key=="phone"){
                setState(() {
               pno=values;
             });
             
           }
   
         });
       });

    });
  }
}
