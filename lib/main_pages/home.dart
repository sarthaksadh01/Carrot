import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pit_carousel/pit_carousel.dart';

import './viewlive.dart';

class Home extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Home> {
  bool loading = true;
  List<Widget> list = [];
  Map<dynamic, dynamic> values;
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            //new
            padding: new EdgeInsets.all(8.0), //new//new
            itemBuilder: (_, int index) {
              return list[index];
            }, //new
            itemCount: list.length,
            //new
          );
  }

  Widget _buildHome(
      String cat, String sub, String uid, String msg_uid,String title, String type) {
    if (type == 'streams') {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewLive(
                      channelName: uid,
                      msgUid: msg_uid,
                    )),
          );
        },
        child: Card(
            elevation: 1.5,
            child: Container(
                width: MediaQuery.of(context).size.width / 1.2,
                height: 350,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Image.network(
                        'https://cdn.pixabay.com/photo/2016/10/27/22/53/heart-1776746_960_720.jpg',
                        height: 230,
                        width: MediaQuery.of(context).size.width / 1.2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                      ),
                      Text(
                        title,
                        style: TextStyle(
                            color: Color(0xfffd6a02),
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                      ),
                      Text(
                        cat,
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ),
                       Padding(
                        padding: EdgeInsets.only(top: 5),
                      ),
                      Text(
                        sub,
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ))),
      );
    } else if (type == 'carousel') {
      return AdvCarousel(
        children: [
          Image.network(
              "http://androidcut.com/wp-content/uploads/2017/07/Boat-River-View-1920x1080-Portrait.jpg",
              fit: BoxFit.cover),
          Image.network(
              "http://androidcut.com/wp-content/uploads/2017/08/Beach-Top-View-Wallpaper-Portrait-1920x1080.jpg",
              fit: BoxFit.cover),
          Image.network(
              "http://www.sompaisoscatalans.cat/simage/8/85501/wallpaper-portrait-android.jpg",
              fit: BoxFit.cover),
          Image.network(
              "https://c.wallhere.com/photos/dd/c9/architecture_building_skyscraper_blueprints_digital_art_3d_object_render_CGI-88920.jpg!d",
              fit: BoxFit.cover),
          Image.network("https://pbs.twimg.com/media/C2dVR-sWEAAaId7.jpg",
              fit: BoxFit.cover),
          Image.network(
              "https://www.gambar.co.id/wp-content/uploads/2018/04/wallpaper-xiaomi-mi-a1-hd-download-hd-wallpapers-of-digital-art-portrait-display-of-wallpaper-xiaomi-mi-a1-hd.png",
              fit: BoxFit.cover),
          Image.network(
              "http://htc-wallpaper.com/wp-content/uploads/2013/11/Moon1.jpg",
              fit: BoxFit.cover),
        ],
        dotAlignment: Alignment.topLeft,
        height: double.infinity,
        animationCurve: Curves.easeIn,
        animationDuration: Duration(milliseconds: 300),
        displayDuration: Duration(seconds: 3),
      );
    } else if (type == 'heading') {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Popular Videos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Icon(Icons.more)
          ],
        ),
      );
    }
  }

  _loadData() async {
 
    final db = FirebaseDatabase.instance.reference().child("Live").orderByChild('status').equalTo('online');
    db.once().then((DataSnapshot snapshot) {
      setState(() {
        values = snapshot.value;
      });

      values.forEach((key, values) {
        setState(() {
          list.add(_buildHome(values['category'], values['hashtags'],
              values['uid'], values['msg_uid'],values['title'], 'streams'));
        });
      });
    });

    setState(() {
      list.add(_buildHome('', '', '', '','', 'heading'));
    });
    setState(() {
      loading = false;
    });
  }
}
