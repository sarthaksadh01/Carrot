import 'package:flutter/material.dart';
import 'package:direct_select/direct_select.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:permission_handler/permission_handler.dart';
import './golive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './golive_screen.dart';

class AddDescFull extends StatefulWidget {
  final String media;
  AddDescFull({this.media});
  @override
  _AddDescFullState createState() => _AddDescFullState();
}

class _AddDescFullState extends State<AddDescFull> {
  List<String> hash = [];
  var hashtagscntrl = new TextEditingController();
  final elements1 = [
    "Art",
    "Dance",
    "Music",
    "Games",
    "Photography",
    "Live Chat",
    "Yoga",
    "Misc"
  ];
  int selectedIndex1 = 0;
  String title = "";

  List<Widget> _buildItems1() {
    return elements1
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfffd6a02),
        title: Text("Go Live!"),
      ),
      body: Center(
          child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 10.0, bottom: 20),
          child: Text(
            "Select Category",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
        DirectSelect(
            itemExtent: 35.0,
            selectedIndex: selectedIndex1,
            child: MySelectionItem(
              isForList: false,
              title: elements1[selectedIndex1],
            ),
            onSelectedItemChanged: (index) {
              setState(() {
                selectedIndex1 = index;
                print(elements1[selectedIndex1]);
              });
            },
            items: _buildItems1()),
        Padding(
          padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
          child: TextField(
            onChanged: (val) {
              setState(() {
                title = val;
              });
            },
            decoration: new InputDecoration(
                prefixIcon: Icon(Icons.calendar_today),
                hintText: "Enter Title",
                border: new OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.teal))),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: hashtagscntrl,
                    decoration: new InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: "Enter #hashtags",
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        if (hashtagscntrl.text.trim() != null)
                          hash.add("#" + hashtagscntrl.text);
                        hashtagscntrl.text = "";
                      });
                    },
                    icon: Icon(
                      Icons.add,
                      color: Color(0xfffd6a02),
                    ),
                  ),
                ),
              ],
            )),
        Expanded(
          // height: 250,
          child: ListView.builder(
            itemCount: hash.length,
            itemBuilder: (BuildContext context, index) {
              return Card(
                // color: Color(0xfffd6a02),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              hash[index],
                              style: TextStyle(
                                  fontSize: 22.0, color: Color(0xfffd6a02)),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                setState(() {
                                  hash.removeAt(index);
                                });
                              },
                            )
                          ],
                        ))),
              );
            },
          ),
        ),
      ])),
      bottomNavigationBar: MaterialButton(
        height: 45,
        color: Color(0xfffd6a02),
        child: Text(
          "Start",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          _golive();
        },
      ),
    );
  }

  _golive() async {
    if (title.trim() == "") {
      Fluttertoast.showToast(
          msg: "Title cannot be empty!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    // await _handleCameraAndMic();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();

    String tags = "";
    for (int i = 0; i < hash.length; i++) {
      tags += hash[i];
      tags += " ";
    }
    if (widget.media == "Camera") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GoLive(
                  channelName: user.uid,
                  category: elements1[selectedIndex1],
                  hashtags: tags.trim(),
                  title: title.trim(),
                )),
      );
    } else {
      Navigator.of(context).push(new MaterialPageRoute(
          settings: const RouteSettings(name: '/ScreenRecord'),
          builder: (context) => new ScreenRecord(
                channelName: user.uid,
                category: elements1[selectedIndex1],
                hashtags: tags.trim(),
                title: title.trim(),
              )));
    }
  }

  // _handleCameraAndMic() async {
  //   await PermissionHandler().requestPermissions(
  //       [PermissionGroup.camera, PermissionGroup.microphone]);
  // }
}

class MySelectionItem extends StatelessWidget {
  final String title;
  final bool isForList;

  const MySelectionItem({Key key, this.title, this.isForList = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: isForList
          ? Padding(
              child: _buildItem(context),
              padding: EdgeInsets.all(10.0),
            )
          : Card(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: <Widget>[
                  _buildItem(context),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_drop_down),
                  )
                ],
              ),
            ),
    );
  }

  _buildItem(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Text(title),
    );
  }
}
