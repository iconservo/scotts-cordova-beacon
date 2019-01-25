package com.scotts.cordova.beacon;

import android.content.Context;
import android.util.Log;

import java.lang.Exception;

import org.altbeacon.beacon.Beacon;
import org.altbeacon.beacon.BeaconManager;
import org.altbeacon.beacon.BeaconParser;
import org.altbeacon.beacon.Identifier;
import org.altbeacon.beacon.Region;
import org.altbeacon.beacon.startup.BootstrapNotifier;
import org.altbeacon.beacon.startup.RegionBootstrap;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;

public class ScottsBeacon extends CordovaPlugin implements BootstrapNotifier {

    public static final String TAG = ScottsBeacon.class.getSimpleName();

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

        mBeaconManager = BeaconManager.getInstanceForApplication(sApplicationContext);
        mBeaconManager.getBeaconParsers().add(
                new BeaconParser().setBeaconLayout("m:0-3=4c000215,i:4-19,i:20-21,i:22-23,p:24-24")
        );

        sRegionBootstrap = new RegionBootstrap(this,
                new Region("water_low",
                        Identifier.parse("58A78BF8-E280-48A4-8668-B8D8CF947CF8"),
                        Identifier.parse("1"),
                        Identifier.parse("64"))
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
        //sRegionBootstrap.disable();
    }

    @Override
    public void didExitRegion(Region region) {
        Log.d(TAG, "didExitRegion: " + (region == null ? "-" : region.toString()));
    }
}
