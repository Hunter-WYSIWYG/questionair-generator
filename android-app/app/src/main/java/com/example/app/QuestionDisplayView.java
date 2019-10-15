package com.example.app;

import android.content.Context;
import android.content.Intent;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

public abstract class QuestionDisplayView extends FrameLayout {
	
	public QuestionDisplayView(Context context, Intent intent) {
		super(context);
	}
	
	public QuestionDisplayView(Context context, AttributeSet attrs, Intent intent) {
		super(context, attrs);
		this.intent = intent;
	}
	
	public QuestionDisplayView(Context context, AttributeSet attrs, int defStyle, Intent intent) {
		super(context, attrs, defStyle);
		this.intent = intent;
	}
	
	private final Intent intent;
	public Intent getIntent() {
		return this.intent;
	}
	
}
