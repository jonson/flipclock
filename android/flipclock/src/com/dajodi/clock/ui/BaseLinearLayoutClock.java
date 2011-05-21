package com.dajodi.clock.ui;

import java.util.TimeZone;

import android.content.Context;
import android.text.format.Time;
import android.util.AttributeSet;
import android.widget.LinearLayout;

import com.dajodi.clock.ui.ClockHelper.OnTimeChangeListener;

/**
 * Abstract LinearLayout based clock.  Can (should) be extended by widgets that
 * need clock functionality that are also based on a LinearLayout.
 * 
 * @author jonson
 *
 */
public abstract class BaseLinearLayoutClock extends LinearLayout implements Clock {

	private final ClockHelper helper;
	
	public BaseLinearLayoutClock(Context context, AttributeSet attrs) {
		super(context, attrs);
		
		helper = new ClockHelper(new OnTimeChangeListener() {
			@Override
			public void handleTimeChange(Time now) {
				onTimeChanged(now);
			}
		});
	}

	public BaseLinearLayoutClock(Context context) {
		this(context, null);
	}
	
	@Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        helper.onAttachToWindow(getContext());        
    }
	
	@Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        helper.onDetachedFromWindow(getContext());
    }
	
	@Override
	public void setTimeZone(TimeZone timeZone) {
		helper.setTimeZone(timeZone);
	}
	
	protected Time getNow() {
		return helper.mCalendar;
	}

}
