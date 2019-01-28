package com.scotts.cordova.beacon;

import android.util.Log;

import java.lang.Exception;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;

import org.json.JSONArray;
import org.json.JSONException;

public class ScottsBeacon extends CordovaPlugin {

    public static final String TAG = ScottsBeacon.class.getSimpleName();

    public ScottsBeacon() {
        Log.d(TAG, "ScottsBeacon");
    }

    @Override
    public boolean execute(String action, JSONArray data, CallbackContext callbackContext) throws JSONException {
        return action.equals("initializeScottsBeacon");
    }

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        try {
            ScottsBeaconApplication application =
                (ScottsBeaconApplication) cordova.getActivity().getApplication();
            application.setIsRunning();
        } catch (Exception e) {
            // Do nothing.
        }

        Log.d(TAG, "initialize: beacons are handled through a custom Application class");
    }
}
