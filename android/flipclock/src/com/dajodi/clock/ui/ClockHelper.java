package com.dajodi.clock.ui;

import java.util.TimeZone;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.text.format.Time;

/**
 * Helper class that handles common dirty work of a clock.
 * 
 * This helper requires a {@link OnTimeChangeListener}, which currently
 * only supports per-minute updates.
 * 
 * @author jonson
 *
 */
public class ClockHelper {

	protected boolean mAttached;
	protected Time mCalendar;
	protected TimeZone mTimeZone;
	protected final Handler mHandler = new Handler();
	
	private final OnTimeChangeListener timeChangeHandler;
	
	public ClockHelper(OnTimeChangeListener timeChangeHandler) {
		this.timeChangeHandler = timeChangeHandler;
	}


	public void onAttachToWindow(Context context) {
		
		if (!mAttached) {
            mAttached = true;
            IntentFilter filter = new IntentFilter();

            filter.addAction(Intent.ACTION_TIME_TICK);
            filter.addAction(Intent.ACTION_TIME_CHANGED);

            context.registerReceiver(mIntentReceiver, filter, null, mHandler);
        }

        // NOTE: It's safe to do these after registering the receiver since the receiver always runs
        // in the main thread, therefore the receiver can't run before this method returns.

        // The time zone may have changed while the receiver wasn't registered, so update the Time
        mCalendar = new Time();
        mCalendar.setToNow();
        
        // trigger an updated
        timeChangeHandler.handleTimeChange(mCalendar);
	}
	
	
    public void onDetachedFromWindow(Context context) {
        if (mAttached) {
            context.unregisterReceiver(mIntentReceiver);
            mAttached = false;
        }
    }
    
    private final BroadcastReceiver mIntentReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            mCalendar.setToNow();
            timeChangeHandler.handleTimeChange(mCalendar);
        }
    };
    
    /**
     * Sets the timezone, should be run from the UI thread.
     * 
     * @param timeZone
     */
    public void setTimeZone(TimeZone timeZone) {
		this.mTimeZone = timeZone;
		this.mCalendar = new Time(timeZone.getID());
		this.mCalendar.set(System.currentTimeMillis());
		timeChangeHandler.handleTimeChange(mCalendar);
    }
    
    public interface OnTimeChangeListener {
    	public void handleTimeChange(Time now);
    }
}
