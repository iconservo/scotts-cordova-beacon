package com.scotts.cordova.beacon;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.lang.Exception;

import org.altbeacon.beacon.Beacon;
import org.altbeacon.beacon.BeaconManager;
import org.altbeacon.beacon.BeaconParser;
import org.altbeacon.beacon.Identifier;
import org.altbeacon.beacon.RangeNotifier;
import org.altbeacon.beacon.Region;
import org.altbeacon.beacon.startup.BootstrapNotifier;
import org.altbeacon.beacon.startup.RegionBootstrap;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;

public class ScottsBeacon extends CordovaPlugin implements BootstrapNotifier {

    public static final String TAG = "com.scotts.beacon";

    private static Context sApplicationContext;
    private static RegionBootstrap sRegionBootstrap;

    private BeaconManager mBeaconManager;

    public ScottsBeacon() {
        Log.d(TAG, "ScottsBeacon");
    }

    /**
     * Sets the context of the Command. This can then be used to do things like
     * get file paths associated with the Activity.
     *
     * @param cordova The context of the main Activity.
     * @param webView The CordovaWebView Cordova is running in.
     */
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        Log.d(TAG, "initialize");

        sApplicationContext = cordova.getActivity().getApplicationContext();

        mBeaconManager = BeaconManager.getInstanceForApplication(context);
        mBeaconManager.getBeaconParsers().add(
                new BeaconParser().setBeaconLayout("m:0-3=4c000215,i:4-19,i:20-21,i:22-23,p:24-24")
        );

        sRegionBootstrap = new RegionBootstrap(context,
                new Region("water_low",
                        "58A78BF8-E280-48A4-8668-B8D8CF947CF8",
                        "1",
                        "64")
        );
    }

    public Context getApplicationContext() {
        return sApplicationContext;
    }

    @Override
    public void didDetermineStateForRegion(int state, Region region) {
        Log.d(TAG, "didDetermineStateForRegion: " + state + ", " + (region == null ? "-" : region.toString()));
    }

    @Override
    public void didEnterRegion(Region region) {
        Log.d(TAG, "didEnterRegion: " + (region == null ? "-" : region.toString()));
        // This call to disable will make it so the activity below only gets launched the first time a beacon is seen (until the next time the app is launched)
        // if you want the Activity to launch every single time beacons come into view, remove this call.
        //sRegionBootstrap.disable();
        Intent intent = new Intent(this, MainActivity.class);
        // IMPORTANT: in the AndroidManifest.xml definition of this activity, you must set android:launchMode="singleInstance" or you will get two instances
        // created when a user launches the activity manually and it gets launched from here.
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        this.startActivity(intent);
    }

    @Override
    public void didExitRegion(Region region) {
        Log.d(TAG, "didExitRegion: " + (region == null ? "-" : region.toString()));
    }

    @Override
    public void didRangeBeaconsInRegion(java.util.Collection<Beacon> beacons, Region region) {
        Log.d(TAG, "didRangeBeaconsInRegion: " + (region == null ? "-" : region.toString()));
        if (beacons != null) {
            for (Beacon beacon : beacons) {
                Log.d(TAG, "beacon: " + beacon.toString());
            }
        }
    }
}
