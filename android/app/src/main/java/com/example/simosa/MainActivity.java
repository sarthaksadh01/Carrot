package com.example.simosa;

import android.content.Intent;
import android.os.Bundle;
import android.os.Parcel;

import java.lang.reflect.Method;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    final String CHANNEL = "samples.flutter.io/screen_record";

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
        new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                // TODO

                  if (call.method.equals("startScreenShare")) {

                      MyInterface myInterface = new MyInterface() {
                          @Override
                          public int describeContents() {
                              return 0;
                          }

                          @Override
                          public void writeToParcel(Parcel parcel, int i) {

                          }

                          @Override
                          public void join(String s) {
                              result.success(s);
                          }

                          @Override
                          public void error(String s) {
                              result.success(s);
                          }

                          @Override
                          public void leave(String s) {
                              result.success(s);
                          }
                      } ;
                      Intent intent = new Intent(MainActivity.this , HelloAgoraScreenSharingActivity.class);

                      startActivity(intent);

                } else {
                  result.notImplemented();
                }
              }
          });

  }
}
