package com.scotts.cordova.beacon;

import android.app.Application;
import android.util.Log;

import java.lang.Exception;
import java.util.Collection;

import org.altbeacon.beacon.Beacon;
import org.altbeacon.beacon.BeaconManager;
import org.altbeacon.beacon.BeaconParser;
import org.altbeacon.beacon.Identifier;
import org.altbeacon.beacon.RangeNotifier;
import org.altbeacon.beacon.Region;
import org.altbeacon.beacon.startup.BootstrapNotifier;
import org.altbeacon.beacon.startup.RegionBootstrap;

public class ScottsBeaconApplication extends Application implements BootstrapNotifier, RangeNotifier {

    public static final String TAG = ScottsBeaconApplication.class.getSimpleName();

    private RegionBootstrap mRegionBootstrap;
    private BeaconManager mBeaconManager;

    public void onCreate() {
        Log.d(TAG, "onCreate");

        mBeaconManager = BeaconManager.getInstanceForApplication(this);
        mBeaconManager.getBeaconParsers().add(
                new BeaconParser().setBeaconLayout("m:0-3=4c000215,i:4-19,i:20-21,i:22-23,p:24-24")
        );
        mBeaconManager.setRangeNotifier(this);

        mRegionBootstrap = new RegionBootstrap(this,
                new Region("water_low",
                        Identifier.parse("58A78BF8-E280-48A4-8668-B8D8CF947CF8"),
                        Identifier.parse("1"),
                        Identifier.parse("64"))
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

        try {
            mBeaconManager.startRangingBeaconsInRegion(region);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void didExitRegion(Region region) {
        Log.d(TAG, "didExitRegion: " + (region == null ? "-" : region.toString()));

        try {
            mBeaconManager.stopRangingBeaconsInRegion(region);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void didRangeBeaconsInRegion(Collection<Beacon> beacons, Region region) {
        Log.d(TAG, "didRangeBeaconsInRegion: " + (region == null ? "-" : region.toString()));
        if (beacons == null || beacons.size() == 0) {
            Log.d(TAG, "didRangeBeaconsInRegion: no beacons");
        } else {
            for (Beacon beacon : beacons) {
                Log.d(TAG, "didRangeBeaconsInRegion: found " + beacon.toString());
            }
        }
    }
}
