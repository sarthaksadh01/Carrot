// import 'package:phone_auth_simple/phone_auth_simple.dart';
// import 'package:firebase_database/firebase_database.dart'
// otp == false
          // ?
 // : vfy == false
      // ? PhoneAuthSimple(
      //     countryCode: "+91",
      //     phoneNumber: phone,
      //     onVerificationSuccess: () {
      //       setState(() {
      //         vfy = true;
      //       });
      //       _saveData();
      //     },
      //     onVerificationFailure: () {
      //       setState(() {
      //         vfy = false;
      //         otp = false;
      //       });
      //       _error();
      //     },
      //   )
      // : Center(
      //     child: CircularProgressIndicator(
      //       backgroundColor: Color(0xfffd6a02),
      //     ),
      //   ),

       // setState(() {
    //   otp = true;
    // });

      // final reference =
      //     FirebaseDatabase.instance.reference().child('Users').child(user.uid);
      // reference.set({
      //   'name': name,
      //   'username': uname.trim(),
      //   'email': email,
      //   'phone': phone.trim(),
      //   "dob": t.toString(),
      //   'gender': gender,
      //   'pic': photo,
      //   'time': new DateTime.now().millisecondsSinceEpoch
      // }).then((onValue) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => MyHomePage()),
      //   );
      // });

        // _error() {
  //   Fluttertoast.showToast(
  //       msg: "Error Verifyng phone number!",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIos: 1,
  //       backgroundColor: Color(0xfffd6a02),
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  //   setState(() {
  //     otp = false;
  //   });
  // }

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

  class ListAppsPages extends StatefulWidget {
  @override
  _ListAppsPagesState createState() => _ListAppsPagesState();
}

class _ListAppsPagesState extends State<ListAppsPages> {
  bool _showSystemApps = false;
  bool _onlyLaunchableApps = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Installed applications"),
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                    value: 'system_apps', child: Text('Toggle system apps')),
              ];
            },
            onSelected: (key) {
              if (key == "system_apps") {
                setState(() {
                  _showSystemApps = !_showSystemApps;
                });
              }
            },
          )
        ],
      ),
      body: _ListAppsPagesContent(
          includeSystemApps: _showSystemApps, onlyAppsWithLaunchIntent: _onlyLaunchableApps, key: GlobalKey()),
    );
  }
}

class _ListAppsPagesContent extends StatelessWidget {
  final bool includeSystemApps;
  final bool onlyAppsWithLaunchIntent;

  const _ListAppsPagesContent({Key key, this.includeSystemApps: false, this.onlyAppsWithLaunchIntent: true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DeviceApps.getInstalledApplications(
            includeAppIcons: true, includeSystemApps: includeSystemApps, onlyAppsWithLaunchIntent: onlyAppsWithLaunchIntent),
        builder: (context, data) {
          if (data.data == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            List<Application> apps = data.data;
            print(apps);
            return ListView.builder(
                itemBuilder: (context, position) {
                  Application app = apps[position];
                  return Column(
                    children: <Widget>[
                      ListTile(
                          leading: app is ApplicationWithIcon
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(app.icon),
                                  backgroundColor: Colors.white,
                                )
                              : null,
                          onTap: () => DeviceApps.openApp(app.packageName),
                          title: Text("${app.appName}"),
                        ),
                      Divider(
                        height: 1.0,
                      )
                    ],
                  );
                },
                itemCount: apps.length);
          }
        });
  }
}
