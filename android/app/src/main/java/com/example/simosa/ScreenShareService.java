package com.example.simosa;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.IBinder;

import android.content.Context;
import android.support.annotation.RequiresApi;
import android.support.v4.app.NotificationCompat;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.WindowManager;
import android.widget.Toast;
import android.content.SharedPreferences;

import java.net.URISyntaxException;

import com.github.nkzawa.socketio.client.IO;
import com.github.nkzawa.socketio.client.Socket;
import org.json.JSONObject;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.ss.GLRender;
import io.agora.rtc.ss.ImgTexFrame;
import io.agora.rtc.ss.SinkConnector;
import io.agora.rtc.ss.capture.ScreenCapture;
import io.agora.rtc.video.AgoraVideoFrame;
import io.agora.rtc.video.VideoEncoderConfiguration;

import static android.support.v4.app.NotificationCompat.PRIORITY_HIGH;

public class ScreenShareService extends Service {

    private Socket mSocket;
    {
        try {
            mSocket = IO.socket("https://sarthak-sadh.herokuapp.com");
        } catch (URISyntaxException e) {
        }
    }

    private static final String LOG_TAG = "AgoraScreenSharing";

    private ScreenCapture mScreenCapture;
    private GLRender mScreenGLRender;

    private RtcEngine mRtcEngine;

    private boolean mIsLandSpace = false;
    private VideoEncoderConfiguration mVEC;

    String uid = "";

    @Override
    public IBinder onBind(Intent intent) {
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Intent i = new Intent(this, HelloAgoraScreenSharingActivity.class);
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, i, 0);

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        String channelId = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ? createNotificationChannel(notificationManager)
                : "";
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, channelId);
        Notification notification = notificationBuilder.setOngoing(true).setSmallIcon(R.mipmap.ic_launcher)
                .setPriority(PRIORITY_HIGH).setContentIntent(pendingIntent).setAutoCancel(true)
                .setCategory(NotificationCompat.CATEGORY_SERVICE).setContentTitle("You are live!")
                .addAction(R.mipmap.ic_launcher, "stop", pendingIntent).build();

        startForeground(101, notification);

        return START_STICKY;
    }

    @Override
    public void onCreate() {

        Intent i = new Intent(this, HelloAgoraScreenSharingActivity.class);
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, i, 0);

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        String channelId = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                ? createNotificationChannel(notificationManager)
                : "";
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, channelId);
        Notification notification = notificationBuilder.setOngoing(true).setSmallIcon(R.mipmap.ic_launcher)
                .setPriority(PRIORITY_HIGH).setContentIntent(pendingIntent).setAutoCancel(true)
                .setCategory(NotificationCompat.CATEGORY_SERVICE).setContentTitle("You are live!")
                .addAction(R.mipmap.ic_launcher, "stop", pendingIntent).build();

        startForeground(101, notification);

        SharedPreferences prefs = getSharedPreferences("MY_PREFS_NAME", MODE_PRIVATE);
        uid = prefs.getString("uid", "null");
        mSocket.connect();
        JSONObject jObjectType = new JSONObject();
       try {
        jObjectType.put("uid", uid);
       } catch (Exception e) {
           //TODO: handle exception
       }
        mSocket.emit("userLive", jObjectType);
        initModules();
        startCapture();
        mRtcEngine.muteAllRemoteAudioStreams(true);
        mRtcEngine.muteAllRemoteVideoStreams(true);
        mRtcEngine.joinChannel(null, uid, "", 0);

    }

    @RequiresApi(Build.VERSION_CODES.O)
    private String createNotificationChannel(NotificationManager notificationManager) {
        String channelId = "my_service_channelid";
        String channelName = "My Foreground Service";
        NotificationChannel channel = new NotificationChannel(channelId, channelName,
                NotificationManager.IMPORTANCE_HIGH);
        // omitted the LED color
        channel.setImportance(NotificationManager.IMPORTANCE_HIGH);
        channel.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        notificationManager.createNotificationChannel(channel);
        return channelId;
    }

    @Override
    public void onDestroy() {
        Toast.makeText(this, "Service stopped", Toast.LENGTH_LONG).show();
        mRtcEngine.leaveChannel();
        stopCapture();
        deInitModules();
        mSocket.disconnect();
    }

    private void initModules() {
        DisplayMetrics metrics = new DisplayMetrics();
        WindowManager window = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
        window.getDefaultDisplay().getMetrics(metrics);

        if (mScreenGLRender == null) {
            mScreenGLRender = new GLRender();
        }
        if (mScreenCapture == null) {
            mScreenCapture = new ScreenCapture(getApplicationContext(), mScreenGLRender, metrics.densityDpi);
        }

        mScreenCapture.mImgTexSrcConnector.connect(new SinkConnector<ImgTexFrame>() {
            @Override
            public void onFormatChanged(Object obj) {
                // Log.d(LOG_TAG, "onFormatChanged " + obj.toString());
            }

            @Override
            public void onFrameAvailable(ImgTexFrame frame) {
                // Log.d(LOG_TAG, "onFrameAvailable " + frame.toString());

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
                    stoppService("Screen sharing not supported");
                    break;
                case ScreenCapture.SCREEN_ERROR_PERMISSION_DENIED:
                    stoppService("Permission denied");
                    // stopSelf();
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
                                // mSocket.connect();
                                // mSocket.emit("userLive", ScreenShareService.this.uid);

                            }

                            @Override
                            public void onWarning(int warn) {
                                Log.d(LOG_TAG, "onWarning " + warn);
                            }

                            @Override
                            public void onError(int err) {
                                Log.d(LOG_TAG, "onError " + err);
                                stoppService("err");
                            }

                            @Override
                            public void onAudioRouteChanged(int routing) {
                                // Log.d(LOG_TAG, "onAudioRouteChanged " + routing);
                            }
                        });
            } catch (Exception e) {
                Log.e(LOG_TAG, Log.getStackTraceString(e));
                stoppService("Error");

                throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
            }

            mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
            mVEC = new VideoEncoderConfiguration(VideoEncoderConfiguration.VD_1280x720,
                    VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_30, VideoEncoderConfiguration.STANDARD_BITRATE,
                    VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_ADAPTIVE);
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

    public void stoppService(String err) {

        Toast.makeText(ScreenShareService.this, err + " nothing was recorded!", Toast.LENGTH_LONG).show();
        stopSelf();

    }
}
