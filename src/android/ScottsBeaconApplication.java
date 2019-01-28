package com.scotts.cordova.beacon;

import android.app.Application;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Icon;
import android.os.Build;
import android.util.Log;

import java.lang.Exception;
import java.util.Collection;

import org.altbeacon.beacon.Beacon;
import org.altbeacon.beacon.BeaconManager;
import org.altbeacon.beacon.BeaconParser;
import org.altbeacon.beacon.Identifier;
import org.altbeacon.beacon.Region;
import org.altbeacon.beacon.startup.BootstrapNotifier;
import org.altbeacon.beacon.startup.RegionBootstrap;

public class ScottsBeaconApplication extends Application implements BootstrapNotifier {

    public static final String TAG = ScottsBeaconApplication.class.getSimpleName();

    private static final String WATER = "com.scotts.beacon.mg12.water";
    private static final String PUMP = "com.scotts.beacon.mg12.pump";
    private static final String CHANNEL_ID = "com.scotts.beacon.mg12.notification";

    private RegionBootstrap mRegionBootstrap;
    private BeaconManager mBeaconManager;

    public void onCreate() {
        Log.d(TAG, "onCreate");

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager notificationManager =
                        (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.createNotificationChannel(
                new NotificationChannel(CHANNEL_ID, "Miracle-Gro Twelve",
                    NotificationManager.IMPORTANCE_HIGH));
        }

        mBeaconManager = BeaconManager.getInstanceForApplication(this);
        mBeaconManager.getBeaconParsers().add(
                new BeaconParser().setBeaconLayout("m:0-3=4c000215,i:4-19,i:20-21,i:22-23,p:24-24")
        );

        mRegionBootstrap = new RegionBootstrap(this,
                new Region(WATER,
                        Identifier.parse("58A78BF8-E280-48A4-8668-B8D8CF947CF8"),
                        Identifier.parse("1"),
                        Identifier.parse("64"))
        );
        mRegionBootstrap.addRegion(
            new Region(PUMP,
                        Identifier.parse("58A78BF8-E280-48A4-8668-B8D8CF947CF8"),
                        Identifier.parse("1"),
                        Identifier.parse("32"))
        );
    }

    @Override
    public void didDetermineStateForRegion(int state, Region region) {
        Log.d(TAG, "didDetermineStateForRegion: " + state + ", " + (region == null ? "-" : region.toString()));

        if (state == BootstrapNotifier.INSIDE) {
            this.didEnterRegion(region);
        }
    }

    @Override
    public void didEnterRegion(Region region) {
        Log.d(TAG, "didEnterRegion: " + (region == null ? "-" : region.toString()));

        Notification.Builder notificationBuilder = new Notification.Builder(this);
        notificationBuilder.setAutoCancel(true);
        notificationBuilder.setLargeIcon(Icon.createWithResource(this, com.scotts.mg12.R.mipmap.icon));
        notificationBuilder.setSmallIcon(android.R.drawable.stat_notify_error);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationBuilder.setChannelId(CHANNEL_ID);
        }
        notificationBuilder.setContentIntent(PendingIntent.getActivity(this, 0,
            new Intent(this, com.scotts.mg12.MainActivity.class), Intent.FLAG_ACTIVITY_NEW_TASK));

        if (WATER.equals(region.getUniqueId())) {
            Log.d(TAG, "Found WATER beacon.");
            notificationBuilder.setContentTitle("Low Water Level");
            notificationBuilder.setContentText("The water level is low. Please refill the water tank.");
        } else if (PUMP.equals(region.getUniqueId())) {
            Log.d(TAG, "Found PUMP beacon.");
            notificationBuilder.setContentTitle("Pump Failure");
            notificationBuilder.setContentText("The pump is not running. Please check your device.");
        }

        NotificationManager notificationManager =
                    (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.notify(0, notificationBuilder.build());
    }

    @Override
    public void didExitRegion(Region region) {
        Log.d(TAG, "didExitRegion: " + (region == null ? "-" : region.toString()));

        if (WATER.equals(region.getUniqueId())) {
            Log.d(TAG, "Lost WATER beacon.");
        } else if (PUMP.equals(region.getUniqueId())) {
            Log.d(TAG, "Lost PUMP beacon.");
        }
    }
}
