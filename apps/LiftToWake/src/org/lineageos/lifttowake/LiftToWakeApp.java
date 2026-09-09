/*
 * vivo 1907N lift-to-wake.
 *
 * AOSP's "Lift to check phone" (SystemUI DozeSensors) hard-codes
 * Sensor.TYPE_PICK_UP_GESTURE (25). This device's sensor HAL only exposes the
 * vivo private "android.sensor.raiseup_detect" (type 66538 - wake-up, one-shot,
 * special-trigger), which Funtouch uses for the same feature. Watch it while the
 * screen is off and wake on a raise.
 *
 * Runs as a persistent platform app (started early by AMS, no boot receiver,
 * no foreground-service notification). Toggle:
 *   settings put system lift_to_wake 0        (default: 1 = on)
 */
package org.lineageos.lifttowake;

import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.ContentObserver;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.TriggerEvent;
import android.hardware.TriggerEventListener;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.os.SystemClock;
import android.provider.Settings;
import android.util.Log;

public class LiftToWakeApp extends Application {
    private static final String TAG = "LiftToWake";
    private static final String RAISEUP_STRING_TYPE = "android.sensor.raiseup_detect";
    private static final int RAISEUP_INT_TYPE = 66538;
    private static final String SETTING = "lift_to_wake";

    private SensorManager mSensorManager;
    private PowerManager mPowerManager;
    private Sensor mSensor;

    private boolean mScreenOff = false;
    private boolean mEnabled = true;
    private boolean mListening = false;

    private boolean mUsingListener = false;

    private void doWake() {
        Log.i(TAG, "raise detected, waking");
        mPowerManager.wakeUp(SystemClock.uptimeMillis(),
                PowerManager.WAKE_REASON_GESTURE, TAG + ":lift");
        // ACTION_SCREEN_ON follows and updateState() re-evaluates
    }

    private final TriggerEventListener mTrigger = new TriggerEventListener() {
        @Override
        public void onTrigger(TriggerEvent event) {
            mListening = false; // one-shot: auto-disarms after firing
            doWake();
        }
    };

    private final SensorEventListener mListener = new SensorEventListener() {
        @Override
        public void onSensorChanged(SensorEvent event) {
            if (event.values.length > 0 && event.values[0] == 0f) {
                return; // some builds also report a 0 "reset"
            }
            doWake();
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
        }
    };

    private final BroadcastReceiver mScreenReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String a = intent.getAction();
            if (Intent.ACTION_SCREEN_OFF.equals(a)) {
                mScreenOff = true;
            } else if (Intent.ACTION_SCREEN_ON.equals(a)) {
                mScreenOff = false;
            }
            updateState();
        }
    };

    private final ContentObserver mSettingObserver =
            new ContentObserver(new Handler(Looper.getMainLooper())) {
        @Override
        public void onChange(boolean selfChange) {
            mEnabled = readSetting();
            updateState();
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();

        mSensorManager = getSystemService(SensorManager.class);
        mPowerManager = getSystemService(PowerManager.class);

        mSensor = mSensorManager.getDefaultSensor(RAISEUP_INT_TYPE, true /* wakeUp */);
        if (mSensor == null) {
            mSensor = findRaiseupSensor();
        }
        if (mSensor == null) {
            Log.w(TAG, "no " + RAISEUP_STRING_TYPE + " sensor - idle");
            return;
        }
        Log.i(TAG, "sensor: " + mSensor.getStringType() + " type=" + mSensor.getType()
                + " wakeup=" + mSensor.isWakeUpSensor()
                + " reportingMode=" + mSensor.getReportingMode());

        mEnabled = readSetting();
        mScreenOff = !mPowerManager.isInteractive();

        final IntentFilter f = new IntentFilter();
        f.addAction(Intent.ACTION_SCREEN_ON);
        f.addAction(Intent.ACTION_SCREEN_OFF);
        registerReceiver(mScreenReceiver, f);

        getContentResolver().registerContentObserver(
                Settings.System.getUriFor(SETTING), false, mSettingObserver);

        updateState();
    }

    private Sensor findRaiseupSensor() {
        if (mSensorManager == null) {
            return null;
        }
        for (Sensor s : mSensorManager.getSensorList(Sensor.TYPE_ALL)) {
            if (RAISEUP_STRING_TYPE.equals(s.getStringType())
                    || s.getType() == RAISEUP_INT_TYPE) {
                return s;
            }
        }
        return null;
    }

    private boolean readSetting() {
        final ContentResolver cr = getContentResolver();
        return Settings.System.getInt(cr, SETTING, 1) != 0;
    }

    private synchronized void updateState() {
        if (mSensor == null) {
            return;
        }
        final boolean want = mScreenOff && mEnabled;
        if (want && !mListening) {
            if (mSensorManager.requestTriggerSensor(mTrigger, mSensor)) {
                mUsingListener = false;
                mListening = true;
                Log.i(TAG, "armed (trigger)");
            } else if (mSensorManager.registerListener(mListener, mSensor,
                    SensorManager.SENSOR_DELAY_NORMAL)) {
                mUsingListener = true;
                mListening = true;
                Log.i(TAG, "armed (listener)");
            } else {
                Log.w(TAG, "could not arm the sensor");
            }
        } else if (!want && mListening) {
            if (mUsingListener) {
                mSensorManager.unregisterListener(mListener, mSensor);
            } else {
                mSensorManager.cancelTriggerSensor(mTrigger, mSensor);
            }
            mListening = false;
            Log.i(TAG, "disarmed");
        }
    }
}
