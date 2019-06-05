package com.example.simosa;

import android.app.Activity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;


public class HelloAgoraScreenSharingActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_hello_agora_screen_sharing);

    }


    public void stop(View view) {
        stopService(new Intent(HelloAgoraScreenSharingActivity.this, ScreenShareService.class));
        Intent i = new Intent(HelloAgoraScreenSharingActivity.this,MainActivity.class);
        startActivity(i);
        finish();
    }
}
