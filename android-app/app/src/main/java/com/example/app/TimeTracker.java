package com.example.app;

import android.app.Activity;
import android.content.Intent;

import org.jetbrains.annotations.NotNull;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

public enum TimeTracker {
	;
	private static final ExecutorService es = Executors.newCachedThreadPool();
	private static final AtomicReference<Activity> context = new AtomicReference<>(null);
	private static final AtomicBoolean isRunning = new AtomicBoolean(false);
	private static final AtomicReference<Future<?>> handle = new AtomicReference<>(null);

	public static void startTimer(@NotNull final String timeString) {
		final long millis = parseTimeString(timeString);
		isRunning.set(true);
		handle.set(es.submit(() -> {
			try {
				Thread.sleep(millis);
			} catch (InterruptedException e) {
				e.printStackTrace();
				return;
			}
			isRunning.set(false);
			final Activity displayContext = context.get();
			if (displayContext != null) {
				final Intent intent = new Intent(displayContext, QuestionnaireFinishedActivity.class);
				intent.putExtra("fromTimeTracker", true);
				displayContext.startActivity(intent);
				displayContext.finish();
			}
		}));
	}

	private static long parseTimeString(@NotNull final String timeString) {
		//assumes format HH:MM:SS
		//note: this could overflow for very long editTimes
		// TODO : maybe change this to use DateTime? would make long editTimes possible
		final String[] strings = timeString.split(":");
		return 3600000L * Long.parseLong(strings[0]) + 60000L * Long.parseLong(strings[1]) + 1000L * Long.parseLong(strings[2]);
	}

	public static boolean isTimeOver() {
		if (handle.get() == null) {
			return false;
		} else {
			return !isRunning.get();
		}
	}

	public static void setContext(@NotNull final Activity newContext) {
		context.set(newContext);
	}

	public static void finish() {
		handle.get().cancel(true);
		handle.set(null);
		context.set(null);
		isRunning.set(false);
	}
}
