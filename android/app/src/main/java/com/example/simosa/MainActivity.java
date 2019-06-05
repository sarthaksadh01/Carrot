package com.example.simosa;

import android.Manifest;
import android.app.AlertDialog;

import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;

import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import io.flutter.plugin.common.MethodChannel.Result;

import android.widget.Toast;
import android.content.SharedPreferences;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// import org.graalvm.compiler.lir.constopt.ConstantTree.Flags;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  String uid;
  int flag = 1;
  Result r;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    final String CHANNEL = "samples.flutter.io/screen_record";

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, Result result) {

        if (call.method.equals("startScreenShare")) {
          String uid;
          uid = call.argument("uid");
          SharedPreferences.Editor editor = getSharedPreferences("MY_PREFS_NAME", MODE_PRIVATE).edit();
          editor.putString("uid", uid);

          editor.apply();
          Intent serviceIntent = new Intent(MainActivity.this, ScreenShareService.class);

          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent);
          } else {
            startService(serviceIntent);
          }

          // startService(serviceIntent);
          result.success("started");
          // startService(new Intent(MainActivity.this, ScreenShareService.class));

        } else if (call.method.equals("stopScreenShare")) {
          stopService(new Intent(MainActivity.this, ScreenShareService.class));
          result.success("stopped");

        } else if (call.method.equals("requestPermission")) {
          r = result;

          boolean ans = checkAndRequestPermissions();

        }

        else if (call.method.equals("openSettings")) {
          Intent intent = new Intent();
          intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
          Uri uri = Uri.fromParts("package", getPackageName(), null);
          intent.setData(uri);
          startActivity(intent);
          result.success("done");
        }

        else if(call.method.equals("openApp")){
          String packageName;
          packageName = call.argument("packageName");
          Intent launchIntent = getPackageManager().getLaunchIntentForPackage(packageName);
           startActivity( launchIntent );
          result.success("done");
        }

        else {
          result.notImplemented();
        }
      }
    });

  }

  private boolean checkAndRequestPermissions() {
    int permissionSendMessage = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
    int locationPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO);
    List<String> listPermissionsNeeded = new ArrayList<>();
    if (locationPermission != PackageManager.PERMISSION_GRANTED) {
      listPermissionsNeeded.add(Manifest.permission.RECORD_AUDIO);
    }
    if (permissionSendMessage != PackageManager.PERMISSION_GRANTED) {
      listPermissionsNeeded.add(Manifest.permission.CAMERA);
    }
    if (!listPermissionsNeeded.isEmpty()) {
      ActivityCompat.requestPermissions(this, listPermissionsNeeded.toArray(new String[listPermissionsNeeded.size()]),
          1);
      return false;
    }
    r.success("granted");
    return true;
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
    // Log.d(TAG, "Permission callback called-------");
    switch (requestCode) {
    case 1: {

      Map<String, Integer> perms = new HashMap<>();
      // Initialize the map with both permissions
      perms.put(Manifest.permission.CAMERA, PackageManager.PERMISSION_GRANTED);
      perms.put(Manifest.permission.RECORD_AUDIO, PackageManager.PERMISSION_GRANTED);
      // Fill with actual results from user
      if (grantResults.length > 0) {
        for (int i = 0; i < permissions.length; i++)
          perms.put(permissions[i], grantResults[i]);
        // Check for both permissions
        if (perms.get(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
            && perms.get(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
          r.success("granted");

        } else {

          r.success("denied");

        }
      }
    }
    }

  }

}
