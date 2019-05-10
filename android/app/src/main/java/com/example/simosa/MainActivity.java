package com.example.simosa;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Parcel;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.Toast;

import com.github.nkzawa.socketio.client.IO;
import com.github.nkzawa.socketio.client.Socket;

import java.lang.reflect.Method;
import java.net.URISyntaxException;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.ss.GLRender;
import io.agora.rtc.ss.ImgTexFrame;
import io.agora.rtc.ss.SinkConnector;
import io.agora.rtc.ss.capture.ScreenCapture;
import io.agora.rtc.video.AgoraVideoFrame;
import io.agora.rtc.video.VideoEncoderConfiguration;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private Socket mSocket;
  {
    try {
      mSocket = IO.socket("https://firebase-sockets.herokuapp.com");
    } catch (URISyntaxException e) {
    }
  }

  private static final String LOG_TAG = "AgoraScreenSharing";

  private static final int PERMISSION_REQ_ID_RECORD_AUDIO = 22;

  private ScreenCapture mScreenCapture;
  private GLRender mScreenGLRender;

  private RtcEngine mRtcEngine;

  private boolean mIsLandSpace = false;
  private VideoEncoderConfiguration mVEC;

  String uid;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    final String CHANNEL = "samples.flutter.io/screen_record";

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        // TODO

        if (call.method.equals("startScreenShare")) {
          String uid = call.argument("uid");

          if (startComand(uid)) {
            result.success("started");
          }
          //
          // Intent intent = new Intent(MainActivity.this,
          // HelloAgoraScreenSharingActivity.class);
          // intent.putExtra("uid", uid);
          //
          // startActivity(intent);

        } else if (call.method.equals("stopScreenShare")) {

          if (stopComand()) {
            result.success("stopped");

          }

        } else {
          result.notImplemented();
        }
      }
    });

  }

  private void initModules() {
    DisplayMetrics metrics = new DisplayMetrics();
    getWindowManager().getDefaultDisplay().getMetrics(metrics);

    if (mScreenGLRender == null) {
      mScreenGLRender = new GLRender();
    }
    if (mScreenCapture == null) {
      mScreenCapture = new ScreenCapture(getApplicationContext(), mScreenGLRender, metrics.densityDpi);
    }

    mScreenCapture.mImgTexSrcConnector.connect(new SinkConnector<ImgTexFrame>() {
      @Override
      public void onFormatChanged(Object obj) {
        Log.d(LOG_TAG, "onFormatChanged " + obj.toString());
      }

      @Override
      public void onFrameAvailable(ImgTexFrame frame) {
        Log.d(LOG_TAG, "onFrameAvailable " + frame.toString());

        if (mRtcEngine == null) {
          return;
        }

        AgoraVideoFrame vf = new AgoraVideoFrame();

        vf.format = AgoraVideoFrame.FORMAT_TEXTURE_OES;
        vf.timeStamp = frame.pts;
        vf.stride = frame.mFormat.mWidth;
        vf.height = frame.mFormat.mHeight;
        vf.textureID = frame.mTextureId;
        vf.syncMode = true;
        vf.eglContext14 = mScreenGLRender.getEGLContext();
        vf.transform = frame.mTexMatrix;

        mRtcEngine.pushExternalVideoFrame(vf);
      }
    });

    mScreenCapture.setOnScreenCaptureListener(new ScreenCapture.OnScreenCaptureListener() {
      @Override
      public void onStarted() {
        Log.d(LOG_TAG, "Screen Record Started");
      }

      @Override
      public void onError(int err) {
        Log.d(LOG_TAG, "onError " + err);
        switch (err) {
        case ScreenCapture.SCREEN_ERROR_SYSTEM_UNSUPPORTED:
          break;
        case ScreenCapture.SCREEN_ERROR_PERMISSION_DENIED:
          break;
        }
      }
    });

    WindowManager wm = (WindowManager) getApplicationContext().getSystemService(Context.WINDOW_SERVICE);
    int screenWidth = wm.getDefaultDisplay().getWidth();
    int screenHeight = wm.getDefaultDisplay().getHeight();
    if ((mIsLandSpace && screenWidth < screenHeight) || (!mIsLandSpace) && screenWidth > screenHeight) {
      screenWidth = wm.getDefaultDisplay().getHeight();
      screenHeight = wm.getDefaultDisplay().getWidth();
    }

    setOffscreenPreview(screenWidth, screenHeight);

    if (mRtcEngine == null) {
      try {
        mRtcEngine = RtcEngine.create(getApplicationContext(), "a3615f94f548499eaa79ba7e513b9bb4",
            new IRtcEngineEventHandler() {
              @Override
              public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
                Log.d(LOG_TAG, "onJoinChannelSuccess " + channel + " " + elapsed);

                mSocket.connect();

                // mSocket.emit("LiveUser", "hello");
              }

              @Override
              public void onWarning(int warn) {
                Log.d(LOG_TAG, "onWarning " + warn);
              }

              @Override
              public void onError(int err) {
                Log.d(LOG_TAG, "onError " + err);
              }

              @Override
              public void onAudioRouteChanged(int routing) {
                Log.d(LOG_TAG, "onAudioRouteChanged " + routing);
              }
            });
      } catch (Exception e) {
        Log.e(LOG_TAG, Log.getStackTraceString(e));

        throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
      }

      mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
      mVEC = new VideoEncoderConfiguration(VideoEncoderConfiguration.VD_1280x720,
          VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_30, VideoEncoderConfiguration.STANDARD_BITRATE,
          VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_PORTRAIT);
      mRtcEngine.setVideoEncoderConfiguration(mVEC);
      mRtcEngine.enableVideo();

      if (mRtcEngine.isTextureEncodeSupported()) {
        mRtcEngine.setExternalVideoSource(true, true, true);
      } else {
        throw new RuntimeException(
            "Can not work on device do not supporting texture" + mRtcEngine.isTextureEncodeSupported());
      }

      mRtcEngine.setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
    }
  }

  private void deInitModules() {
    RtcEngine.destroy();
    mRtcEngine = null;

    if (mScreenCapture != null) {
      mScreenCapture.release();
      mScreenCapture = null;
    }

    if (mScreenGLRender != null) {
      mScreenGLRender.quit();
      mScreenGLRender = null;
    }
  }

  public void setOffscreenPreview(int width, int height) throws IllegalArgumentException {
    if (width <= 0 || height <= 0) {
      throw new IllegalArgumentException("Invalid offscreen resolution");
    }

    mScreenGLRender.init(width, height);
  }

  private void startCapture() {
    mScreenCapture.start();
  }

  private void stopCapture() {
    mScreenCapture.stop();
  }

  public boolean startComand(String channel) {

    initModules();
    startCapture();
    mRtcEngine.muteAllRemoteAudioStreams(true);
    mRtcEngine.muteAllRemoteVideoStreams(true);
    mRtcEngine.joinChannel(null, channel, "", 0);

    return true;

  }

  public boolean stopComand() {

    mRtcEngine.leaveChannel();

    stopCapture();

    return true;

  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    deInitModules();
  }

  @Override
  public void onPause() {
    super.onPause();

  }

}
