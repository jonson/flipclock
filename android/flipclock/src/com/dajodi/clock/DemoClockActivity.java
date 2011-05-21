package com.dajodi.clock;

import android.app.Activity;
import android.os.Bundle;

/**
 * Sample activity containing only a digital clock.
 * 
 * @author jonson
 *
 */
public class DemoClockActivity extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }
}