import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';


class AddLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: <Widget>[
         Row(
           mainAxisAlignment: MainAxisAlignment.start,
           children: <Widget>[
              Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "sponsored",
              style: TextStyle(fontSize: 17, color: Color(0xfffd6a02)),
            ),
          ),
           ],

         ),
          Container(
            height: 250,
            child: AdmobBanner(
              adUnitId: 'ca-app-pub-3940256099942544/6300978111',
              adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 15),)
        ],
      ),
    );
  }
}
